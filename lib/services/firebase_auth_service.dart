import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  // Singleton pattern
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  int? _resendToken;

  // Phone number verification send karna
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String, int?) onCodeSent,
    required Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    debugPrint('=== VERIFY PHONE NUMBER STARTED ===');
    debugPrint('Phone: $phoneNumber');
    
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) {
        debugPrint('VERIFICATION COMPLETED AUTOMATICALLY: ${credential.providerId}');
        onVerificationCompleted(credential);
      },
      verificationFailed: (e) {
        debugPrint('VERIFICATION FAILED: ${e.code} - ${e.message}');
        onVerificationFailed(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        debugPrint('CODE SENT! ID: $verificationId');
        _verificationId = verificationId;
        _resendToken = resendToken;
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint('CODE AUTO RETRIEVAL TIMEOUT: $verificationId');
        // NOTE: Do NOT overwrite _verificationId here!
        // The codeSent callback already set the correct ID.
        // Overwriting here causes a race condition with manual OTP entry.
        onCodeAutoRetrievalTimeout(verificationId);
      },
      timeout: const Duration(seconds: 120),
      forceResendingToken: _resendToken,
    );
  }

  // OTP verification complete karna
  Future<UserCredential> signInWithOtp(String otp, {String? verificationId}) async {
    final idToUse = verificationId ?? _verificationId;
    
    if (idToUse == null || idToUse.isEmpty) {
      debugPrint('ERROR: No Verification ID available for sign-in');
      debugPrint('  - Passed ID: $verificationId');
      debugPrint('  - Stored ID: $_verificationId');
      throw FirebaseAuthException(
        code: 'invalid-verification-id',
        message: 'The verification ID is missing. Please request a new code.',
      );
    }

    debugPrint('=== SIGNING IN WITH OTP ===');
    debugPrint('Using ID: $idToUse');
    debugPrint('Stored ID: $_verificationId');
    debugPrint('Passed ID: $verificationId');
    debugPrint('OTP: $otp');

    final credential = PhoneAuthProvider.credential(
      verificationId: idToUse,
      smsCode: otp,
    );

    try {
      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint('SIGN IN SUCCESSFUL! UID: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('SIGN IN FAILED: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Current user check karna
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign out karna
  Future<void> signOut() async {
    debugPrint('=== SIGNING OUT ===');
    await _auth.signOut();
    _verificationId = null;
    _resendToken = null;
  }

  // Get verification ID
  String? getVerificationId() => _verificationId;

  // Set verification ID manually (if needed)
  void setVerificationId(String? verificationId) {
    debugPrint('Verification ID manually set to: $verificationId');
    _verificationId = verificationId;
  }

  // Google Sign-In logic
  Future<UserCredential?> signInWithGoogle() async {
    try {
      debugPrint('=== GOOGLE SIGN IN STARTED ===');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        debugPrint('Google Sign-In cancelled by user');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint('GOOGLE SIGN IN SUCCESSFUL! UID: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      debugPrint('GOOGLE SIGN IN FAILED: $e');
      rethrow;
    }
  }

  // Apple Sign-In logic
  Future<UserCredential?> signInWithApple() async {
    try {
      debugPrint('=== APPLE SIGN IN STARTED ===');
      
      // Trigger the authentication flow
      final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create a new credential
      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Once signed in, return the UserCredential
      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint('APPLE SIGN IN SUCCESSFUL! UID: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      debugPrint('APPLE SIGN IN FAILED: $e');
      rethrow;
    }
  }
}
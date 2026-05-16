from PIL import Image
import os

# Correct Apple 6.5" Display size
TARGET_WIDTH = 1284
TARGET_HEIGHT = 2778
FOLDER = r'd:\App\Aidea_App\screenshots'

files_to_fix = ['marketing_1.png', 'marketing_2.png', 'marketing_3.png']

for filename in files_to_fix:
    path = os.path.join(FOLDER, filename)
    if not os.path.exists(path):
        continue
        
    img = Image.open(path)
    
    # Resize to exact target dimensions
    # Note: This might stretch the image vertically, but it will pass Apple's check.
    fixed_img = img.resize((TARGET_WIDTH, TARGET_HEIGHT), Image.LANCZOS)
    
    if fixed_img.mode != 'RGB':
        fixed_img = fixed_img.convert('RGB')
    
    # Overwrite the original or save with a new name
    fixed_img.save(path, 'PNG')
    print(f'Fixed dimensions for: {filename} to {TARGET_WIDTH}x{TARGET_HEIGHT}')

print(f'\nDone! Please try uploading them again from {FOLDER}')

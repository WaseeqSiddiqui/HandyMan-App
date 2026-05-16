from PIL import Image
import os

# Correct Apple 6.5" Display size
TARGET_WIDTH = 1284
TARGET_HEIGHT = 2778
OUTPUT_DIR = r'd:\App\Aidea_App\screenshots'

screenshots = [
    r'C:\Users\cc\Pictures\Customer home.jpg',
    r'C:\Users\cc\Pictures\Customer home (2).jpg',
]

for i, path in enumerate(screenshots, 1):
    img = Image.open(path)
    w, h = img.size
    
    # Crop Android status bar and nav bar
    crop_top = int(h * 0.04)
    crop_bottom = int(h * 0.96)
    img = img.crop((0, crop_top, w, crop_bottom))
    
    # Resize to exact target dimensions
    img = img.resize((TARGET_WIDTH, TARGET_HEIGHT), Image.LANCZOS)
    
    if img.mode != 'RGB':
        img = img.convert('RGB')
    
    # Save as both formats
    img.save(os.path.join(OUTPUT_DIR, f'screenshot_{i}.jpg'), 'JPEG', quality=95)
    img.save(os.path.join(OUTPUT_DIR, f'screenshot_{i}.png'), 'PNG')
    print(f'Saved screenshot_{i} ({TARGET_WIDTH}x{TARGET_HEIGHT})')

print(f'\nDone! Upload these from: {OUTPUT_DIR}')

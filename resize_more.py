from PIL import Image
import os

# Correct Apple 6.5" Display size
TARGET_WIDTH = 1284
TARGET_HEIGHT = 2778
OUTPUT_DIR = r'd:\App\Aidea_App\screenshots'

if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

screenshots = [
    r'C:\Users\cc\Pictures\Customer home.jpg',
    r'C:\Users\cc\Pictures\Customer home (2).jpg',
    r'C:\Users\cc\Pictures\Customer Services.jpg',
    r'C:\Users\cc\Pictures\profile app.jpeg'
]

for i, path in enumerate(screenshots, 1):
    if not os.path.exists(path):
        print(f"Skipping: {path} (Not found)")
        continue
        
    img = Image.open(path)
    w, h = img.size
    
    # Crop Android status bar and nav bar (roughly 4% each)
    crop_top = int(h * 0.04)
    crop_bottom = int(h * 0.96)
    img = img.crop((0, crop_top, w, crop_bottom))
    
    # Resize to exact target dimensions
    img = img.resize((TARGET_WIDTH, TARGET_HEIGHT), Image.LANCZOS)
    
    if img.mode != 'RGB':
        img = img.convert('RGB')
    
    # Save as both formats
    name = os.path.basename(path).split('.')[0]
    img.save(os.path.join(OUTPUT_DIR, f'{name}_fixed.jpg'), 'JPEG', quality=95)
    img.save(os.path.join(OUTPUT_DIR, f'{name}_fixed.png'), 'PNG')
    print(f'Processed: {name} ({TARGET_WIDTH}x{TARGET_HEIGHT})')

print(f'\nDone! All files saved in: {OUTPUT_DIR}')

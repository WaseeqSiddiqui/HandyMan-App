from PIL import Image
import os

# iPad Pro 12.9" / 13" dimensions
IPAD_WIDTH = 2048
IPAD_HEIGHT = 2732
FOLDER = r'd:\App\Aidea_App\screenshots'

# We'll use the marketing images and real screenshots to make iPad versions
source_files = ['marketing_1.png', 'marketing_2.png', 'marketing_3.png', 'Customer home_fixed.png']

for i, filename in enumerate(source_files, 1):
    path = os.path.join(FOLDER, filename)
    if not os.path.exists(path):
        continue
        
    img = Image.open(path)
    
    # Resize to iPad dimensions
    ipad_img = img.resize((IPAD_WIDTH, IPAD_HEIGHT), Image.LANCZOS)
    
    if ipad_img.mode != 'RGB':
        ipad_img = ipad_img.convert('RGB')
    
    output_name = f'ipad_{i}.png'
    ipad_img.save(os.path.join(FOLDER, output_name), 'PNG')
    print(f'Generated iPad screenshot: {output_name}')

print(f'\nDone! iPad screenshots ready in {FOLDER}')

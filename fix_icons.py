from PIL import Image
import os

icon_dir = r'd:\App\Aidea_App\ios\Runner\Assets.xcassets\AppIcon.appiconset'

for filename in os.listdir(icon_dir):
    if filename.endswith('.png'):
        filepath = os.path.join(icon_dir, filename)
        img = Image.open(filepath)
        if img.mode == 'RGBA':
            # Create white background and paste image on it
            background = Image.new('RGB', img.size, (255, 255, 255))
            background.paste(img, mask=img.split()[3])  # Use alpha as mask
            background.save(filepath)
            print(f'Fixed: {filename}')
        else:
            print(f'OK: {filename}')

print('Done! All icons fixed.')

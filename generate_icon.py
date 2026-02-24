import sys
import subprocess
import os

def ensure_pil():
    try:
        from PIL import Image
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow"])

ensure_pil()
from PIL import Image

img_path = 'assets/images/logo.png'
out_path = 'assets/images/app_icon.png'

# Load original logo
img = Image.open(img_path).convert("RGBA")
width, height = img.size

# Background
bg_color = (15, 23, 42, 255) # #0F172A

# Create opaque image
icon_img = Image.new("RGBA", (width, height), bg_color)
icon_img.paste(img, (0, 0), img)
icon_img = icon_img.convert("RGB") # Remove alpha for iOS
icon_img.save(out_path)

print("Saved app icon.")

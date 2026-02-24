import os
import sys

def ensure_pil():
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        import subprocess
        subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow"])

ensure_pil()
from PIL import Image, ImageDraw, ImageFont

img_path = 'assets/images/logo.png'
out_dark_path = 'assets/images/logo_with_text_dark.png'
out_light_path = 'assets/images/logo_with_text_light.png'

# Load original logo
img = Image.open(img_path).convert("RGBA")
width, height = img.size

canvas_size = 1024
logo_size = int(canvas_size * 0.3)
small_img = img.resize((logo_size, logo_size), Image.Resampling.LANCZOS)
logo_x = (canvas_size - logo_size) // 2
logo_y = (canvas_size - logo_size) // 2 - 50

# Font selection
font_paths = [
    "/System/Library/Fonts/Helvetica.ttc",
    "/System/Library/Fonts/Avenir.ttc",
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/Library/Fonts/Arial.ttf"
]
font = None
for fp in font_paths:
    if os.path.exists(fp):
        try:
            font = ImageFont.truetype(fp, 50)
            break
        except:
            pass

if font is None:
    font = ImageFont.load_default()

text = "Energy Pet"

def create_splash(out_path, text_color):
    final_img = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    final_img.paste(small_img, (logo_x, logo_y), small_img)
    draw = ImageDraw.Draw(final_img)
    try:
        bbox = draw.textbbox((0, 0), text, font=font)
        text_w = bbox[2] - bbox[0]
    except AttributeError:
        text_w = draw.textsize(text, font=font)[0]
    text_x = (canvas_size - text_w) // 2
    text_y = logo_y + logo_size + 20
    draw.text((text_x, text_y), text, font=font, fill=text_color)
    final_img.save(out_path)

create_splash(out_dark_path, (255, 255, 255, 255))
create_splash(out_light_path, (15, 23, 42, 255)) # #0F172A

print("Saved light and dark splash images.")

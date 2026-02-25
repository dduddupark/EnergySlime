from PIL import Image

def make_transparent(input_path, output_path):
    img = Image.open(input_path).convert("RGBA")
    data = img.getdata()

    new_data = []
    # Get the background color from the top-left pixel
    bg_color = data[0]

    # Tolerance for background color
    tolerance = 15

    for item in data:
        # Check if the pixel color is close to the background color
        if abs(item[0] - bg_color[0]) < tolerance and \
           abs(item[1] - bg_color[1]) < tolerance and \
           abs(item[2] - bg_color[2]) < tolerance:
            new_data.append((255, 255, 255, 0)) # Transparent
        else:
            new_data.append(item)

    img.putdata(new_data)
    img.save(output_path, "PNG")

make_transparent("assets/images/app_icon.png", "assets/images/app_icon_transparent.png")

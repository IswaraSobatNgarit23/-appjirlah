from PIL import Image, ImageDraw

def round_corners(image_path, output_path, radius):
    img = Image.open(image_path).convert("RGBA")
    w, h = img.size

    # Create a rounded rectangle mask
    mask = Image.new('L', (w, h), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, w, h), radius=radius, fill=255)

    # Apply the mask to the image
    img.putalpha(mask)
    img.save(output_path)
    print(f"Berhasil crop melengkung! Tersimpan di {output_path}")

round_corners('assets/logo.png', 'assets/logo.png', radius=280)

from pathlib import Path
from PIL import Image, ImageDraw
import random

ROOT = Path(__file__).resolve().parents[1]

def rounded(draw, box, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)

def build_background():
    image = Image.new("RGBA", (1280, 720), (7, 29, 22, 255))
    draw = ImageDraw.Draw(image)
    draw.ellipse((-360, 150, 260, 770), outline=(13, 73, 53, 255), width=4)
    draw.ellipse((1020, 150, 1640, 770), outline=(13, 73, 53, 255), width=4)
    draw.line((0, 70, 1280, 70), fill=(213, 168, 85, 255), width=2)
    draw.line((0, 650, 1280, 650), fill=(213, 168, 85, 255), width=2)
    out = ROOT / "sprites" / "spr_menu_background" / "spr_menu_background.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").quantize(colors=8, dither=Image.Dither.NONE).convert("RGBA").save(out)

def build_emblem():
    image = Image.new("RGBA", (220, 180), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    # Cue and 8-ball emblem, transparent for placement over any menu panel.
    draw.line((10, 160, 205, 15), fill=(53, 151, 119, 235), width=7)
    draw.line((14, 169, 212, 23), fill=(232, 183, 76, 135), width=3)
    draw.ellipse((26, 31, 134, 139), fill=(239, 239, 216, 255), outline=(232, 183, 76, 255), width=6)
    draw.ellipse((57, 62, 103, 108), fill=(12, 32, 37, 255))
    draw.text((75, 84), "8", fill=(232, 183, 76, 255), anchor="mm")
    draw.ellipse((151, 69, 194, 112), fill=(239, 239, 216, 255), outline=(53, 151, 119, 255), width=4)
    draw.ellipse((168, 86, 177, 95), fill=(12, 32, 37, 255))
    out = ROOT / "sprites" / "spr_menu_emblem" / "spr_menu_emblem.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    image.save(out)

if __name__ == "__main__":
    build_background()
    build_emblem()

"""Build result-screen button sprites in the mode-select START button style."""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
ASCII = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
FONT_FRAMES = ROOT / "sprites" / "spr_ui_pixel_font" / "frames"
TEMPLATE = (ROOT / "sprites" / "spr_inventory_slot" / "spr_inventory_slot.yy").read_text(encoding="utf-8")
WIDTH, HEIGHT = 300, 54

BUTTONS = (
    ("spr_result_play_again", "PLAY AGAIN", "8b601a71-0001-4a11-8999-000000000001"),
    ("spr_result_play_again_hover", "PLAY AGAIN", "8b601a71-0002-4a11-8999-000000000002"),
    ("spr_result_main_menu", "MAIN MENU", "8b601a71-0003-4a11-8999-000000000003"),
    ("spr_result_main_menu_hover", "MAIN MENU", "8b601a71-0004-4a11-8999-000000000004"),
)

for name, label, frame_id in BUTTONS:
    hover = name.endswith("_hover")
    fill = (238, 190, 82, 255) if hover else (23, 124, 90, 255)
    ink = (24, 33, 33, 255) if hover else (240, 211, 138, 255)
    border = (240, 211, 138, 255)
    image = Image.new("RGBA", (WIDTH, HEIGHT), fill)
    draw = ImageDraw.Draw(image)
    draw.rectangle((0, 0, WIDTH - 1, HEIGHT - 1), outline=border, width=2)
    x = (WIDTH - len(label) * 24) // 2
    for char in label:
        if char != " ":
            number = ASCII.index(char) + 1
            glyph_id = f"9f8e7d6c-{number:04x}-4a11-8999-{number:012x}"
            mask = Image.open(FONT_FRAMES / f"{glyph_id}.png").convert("RGBA").getchannel("A")
            mask = mask.resize((24, 36), Image.Resampling.NEAREST)
            tile = Image.new("RGBA", mask.size, ink)
            image.paste(tile, (x, 9), mask)
        x += 24

    out = ROOT / "sprites" / name
    layer_id = frame_id.replace("-0001-", "-1001-").replace("-0002-", "-1002-").replace("-0003-", "-1003-").replace("-0004-", "-1004-")
    for target in (out / f"{frame_id}.png", out / "frames" / f"{frame_id}.png",
                   out / "layers" / layer_id / f"{frame_id}.png"):
        target.parent.mkdir(parents=True, exist_ok=True)
        image.save(target, format="PNG")
    metadata = (TEMPLATE.replace("spr_inventory_slot", name)
        .replace("2840c51b-21d4-44e0-aeed-8cc6889a6b07", frame_id)
        .replace("15fd28e9-f95c-407a-a5a9-6052df670107", layer_id)
        .replace("963f95d3-4b26-4a6a-a5b5-8cc6889a6b07", frame_id.replace("-000", "-200", 1))
        .replace('"bbox_bottom":75', f'"bbox_bottom":{HEIGHT - 1}')
        .replace('"bbox_right":75', f'"bbox_right":{WIDTH - 1}')
        .replace('"height":76', f'"height":{HEIGHT}')
        .replace('"width":76', f'"width":{WIDTH}')
        .replace('"origin":4', '"origin":0')
        .replace('"xorigin":38', '"xorigin":0')
        .replace('"yorigin":38', '"yorigin":0'))
    (out / f"{name}.yy").write_text(metadata, encoding="utf-8")

print(f"generated {len(BUTTONS)} result button sprites")

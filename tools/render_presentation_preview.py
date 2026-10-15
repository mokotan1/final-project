"""Render a static 1280x720 preview of the prototype presentation layer."""
from pathlib import Path
from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "datafiles" / "presentation_preview.png"


def sprite(name):
    return Image.open(next((ROOT / "sprites" / name / "frames").glob("*.png"))).convert("RGBA")


canvas = Image.new("RGBA", (1280, 720), "#071216")
d = ImageDraw.Draw(canvas)
table = sprite("spr_table")
canvas.alpha_composite(table, (160, 90))

for name, xy in (("spr_ball_player", (450, 330)), ("spr_ball_target", (805, 245)), ("spr_ball_foul", (720, 430))):
    image = sprite(name)
    canvas.alpha_composite(image, (xy[0] - image.width // 2, xy[1] - image.height // 2))

d.rounded_rectangle((24, 22, 330, 88), radius=12, fill="#0a171b")
d.text((40, 30), "POWER", fill="#d5a855")
d.rounded_rectangle((40, 58, 310, 76), radius=8, fill="#2a3c3f")
d.rounded_rectangle((40, 58, 230, 76), radius=8, fill="#edbb4c")
d.rounded_rectangle((920, 22, 1256, 102), radius=12, fill="#0a171b")
d.text((1080, 32), "CHANCES  4 / 5", fill="white")
d.text((1080, 58), "SCORE  1200", fill="white")
d.text((1080, 82), "ITEM GOAL  1200 / 1500", fill="#d5a855")

slot = sprite("spr_inventory_slot").resize((64, 64))
icons = [sprite("spr_item_move"), sprite("spr_item_risk_shot"), sprite("spr_item_remove")]
start_x = 430
d.text((594, 602), "INVENTORY", fill="#d5a855")
for i in range(6):
    x = start_x + i * 76
    canvas.alpha_composite(slot, (x, 626))
    if i < len(icons):
        icon = icons[i]
        canvas.alpha_composite(icon, (x + 6, 632))

OUT.parent.mkdir(parents=True, exist_ok=True)
canvas.convert("RGB").save(OUT, quality=92)
print(OUT)


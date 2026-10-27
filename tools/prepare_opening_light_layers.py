"""Separate the lit menu art into an unlit base and three animated light layers."""
from pathlib import Path
import subprocess
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "datafiles" / "opening_night_city"
lit = Image.open(ART / "opening_city_pixel_quay_1280.png").convert("RGB")
base = lit.copy()

def save_tracked_sprite(name, image):
    paths = subprocess.check_output(
        ["git", "ls-files", "--", f"sprites/{name}/*.png", f"sprites/{name}/frames/*.png", f"sprites/{name}/layers/*/*.png"],
        cwd=ROOT, text=True,
    ).splitlines()
    for path in paths:
        image.save(ROOT / path)

for kind, sprite, dim in (
    ("stars", "spr_menu_stars_glow", .12),
    ("windows", "spr_menu_windows_glow", .18),
    ("neon", "spr_menu_neon_glow", .10),
):
    old = Image.open(ROOT / "sprites" / sprite / f"{sprite}.png").convert("RGBA")
    layer = Image.new("RGBA", lit.size)
    src, mask, dst, under = lit.load(), old.load(), layer.load(), base.load()
    for y in range(lit.height):
        for x in range(lit.width):
            if mask[x, y][3] == 0:
                continue
            r, g, b = src[x, y]
            under[x, y] = (round(r * dim), round(g * dim), round(b * dim))
            dst[x, y] = (r, g, b, 255)
    layer.save(ART / f"opening_{kind}_quay_overlay_1280.png")
    save_tracked_sprite(sprite, layer)

base.save(ART / "opening_city_pixel_quay_unlit_1280.png")
save_tracked_sprite("spr_menu_background", base)

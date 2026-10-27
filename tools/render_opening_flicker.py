"""Render the same menu light timing as obj_menu/Draw_64.gml for art review."""
from pathlib import Path
import math
import subprocess
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "datafiles" / "opening_night_city" / "opening_city_pixel_quay_flicker_preview.mp4"
BG = Image.open(ROOT / "sprites/spr_menu_background/spr_menu_background.png").convert("RGBA")
STARS = Image.open(ROOT / "sprites/spr_menu_stars_glow/spr_menu_stars_glow.png").convert("RGBA")
WINDOWS = Image.open(ROOT / "sprites/spr_menu_windows_glow/spr_menu_windows_glow.png").convert("RGBA")
NEON = Image.open(ROOT / "sprites/spr_menu_neon_glow/spr_menu_neon_glow.png").convert("RGBA")

def overlay(frame, layer, amount, left=0, right=1280):
    if amount <= 0:
        return
    part = layer.crop((left, 0, right, 720))
    part.putalpha(part.getchannel("A").point(lambda a: round(a * amount)))
    frame.alpha_composite(part, (left, 0))

proc = subprocess.Popen([
    "ffmpeg", "-hide_banner", "-loglevel", "error", "-f", "rawvideo",
    "-pixel_format", "rgb24", "-video_size", "1280x720", "-framerate", "12",
    "-i", "-", "-an", "-c:v", "libx264", "-pix_fmt", "yuv420p",
    "-crf", "18", "-y", str(OUT),
], stdin=subprocess.PIPE)
try:
    for n in range(72):
        t = n / 12
        frame = BG.copy()
        overlay(frame, STARS, .18 + .82 * (.5 + .5 * math.sin(t * 2.1)), 0, 640)
        overlay(frame, STARS, .18 + .82 * (.5 + .5 * math.sin(t * 1.6 + 1.9)), 640)
        overlay(frame, WINDOWS, .12 + .88 * (.5 + .5 * math.sin(t * 1.8 + .7)), 0, 640)
        overlay(frame, WINDOWS, .12 + .88 * (.5 + .5 * math.sin(t * 2.3 + 2.4)), 640)
        tick = math.floor(t * 14) % 71
        neon = .02 if tick in (11, 13, 14) else (.48 if tick in (12, 15) else 1)
        overlay(frame, NEON, neon)
        proc.stdin.write(frame.convert("RGB").tobytes())
finally:
    proc.stdin.close()
    if proc.wait() != 0:
        raise RuntimeError("ffmpeg failed")
print(OUT)

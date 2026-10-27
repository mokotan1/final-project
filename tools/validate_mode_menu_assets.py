"""Check the menu's production sprite and its native pixel drawing path."""

from pathlib import Path
import json
import re

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
NAMES = ("spr_assistant_bar_idle",)

for name in NAMES:
    folder = ROOT / "sprites" / name
    metadata = json.loads(re.sub(r",(?=\s*[}\]])", "", (folder / f"{name}.yy").read_text(encoding="utf-8")))
    layer = metadata["layers"][0]["name"]
    for frame in metadata["frames"]:
        frame_id = frame["name"]
        paths = (
            folder / f"{frame_id}.png",
            folder / "frames" / f"{frame_id}.png",
            folder / "layers" / layer / f"{frame_id}.png",
        )
        pixels = []
        for path in paths:
            with Image.open(path) as image:
                assert image.size == (metadata["width"], metadata["height"]), path
                pixels.append(image.convert("RGBA").tobytes())
        assert pixels[0] == pixels[1] == pixels[2], f"frame copies differ: {name}/{frame_id}"

project = json.loads(re.sub(r",(?=\s*[}\]])", "", (ROOT / "final_project.yyp").read_text(encoding="utf-8")))
registered_sprites = {resource["id"]["name"] for resource in project["resources"]}
draw = (ROOT / "objects" / "obj_menu" / "Draw_64.gml").read_text(encoding="utf-8")
for name in (
    "spr_mode_speech_bubble",
    "spr_mode_select_story_states",
    "spr_mode_select_endless_states",
    "spr_mode_select_classic_states",
    "spr_mode_select_start_states",
):
    assert name not in registered_sprites and name not in draw, f"broken texture resource still used: {name}"
for primitive in ("draw_rectangle", "draw_triangle", "pixel_draw_menu_text"):
    assert primitive in draw

print("PASS: idle frames match and mode buttons/bubble use native pixel drawing")

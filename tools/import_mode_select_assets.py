"""Import the approved mode-room concept as separate GameMaker sprite assets.

This script only adds sprite resources. It does not edit rooms or objects.
"""

from copy import deepcopy
from pathlib import Path
import json
import re
import uuid

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
CONCEPT = ROOT / "datafiles" / "menu_mode_concept"
BUTTONS = {
    "story": (695, 90, 1076, 190),
    "endless": (695, 197, 1076, 298),
    "classic": (695, 304, 1076, 406),
    "start": (505, 520, 791, 605),
    "back": (850, 520, 1128, 605),
}


def gm_json(path):
    return json.loads(re.sub(r",\s*([}\]])", r"\1", path.read_text(encoding="utf-8")))


def save_sprite(name, image):
    folder = ROOT / "sprites" / name
    frame_folder = folder / "frames"
    frame_folder.mkdir(parents=True, exist_ok=True)
    frame_id = str(uuid.uuid5(uuid.NAMESPACE_URL, f"{name}/frame/0"))
    layer_id = str(uuid.uuid5(uuid.NAMESPACE_URL, f"{name}/layer/default"))
    image.save(folder / f"{frame_id}.png")
    image.save(frame_folder / f"{frame_id}.png")
    image.save(folder / f"{name}.png")
    layer_folder = folder / "layers" / layer_id
    layer_folder.mkdir(parents=True, exist_ok=True)
    image.save(layer_folder / f"{frame_id}.png")

    sprite = gm_json(ROOT / "sprites" / "spr_assistant_pixel" / "spr_assistant_pixel.yy")
    sprite["%Name"] = sprite["name"] = name
    sprite["width"], sprite["height"] = image.size
    sprite["bbox_left"] = sprite["bbox_top"] = 0
    sprite["bbox_right"] = image.width - 1
    sprite["bbox_bottom"] = image.height - 1
    sprite["origin"] = 0
    sprite["frames"][0]["%Name"] = sprite["frames"][0]["name"] = frame_id
    sprite["layers"][0]["%Name"] = sprite["layers"][0]["name"] = layer_id
    sequence = sprite["sequence"]
    sequence["%Name"] = sequence["name"] = name
    sequence["xorigin"] = sequence["yorigin"] = 0
    key = sequence["tracks"][0]["keyframes"]["Keyframes"][0]
    key["id"] = str(uuid.uuid5(uuid.NAMESPACE_URL, f"{name}/key/0"))
    key["Channels"]["0"]["Id"] = {
        "name": frame_id,
        "path": f"sprites/{name}/{name}.yy",
    }
    (folder / f"{name}.yy").write_text(json.dumps(sprite, indent=2) + "\n", encoding="utf-8")
    return f'    {{"id":{{"name":"{name}","path":"sprites/{name}/{name}.yy",}},}},\n'


def cut_button(source, box):
    button = source.crop(box).convert("RGBA")
    # All approved buttons are framed rectangles. Keep their dark outer edge,
    # and make the tiny crop gutters and stepped corners transparent.
    mask = Image.new("L", button.size)
    draw = ImageDraw.Draw(mask)
    width, height = button.size
    draw.rectangle((3, 3, width - 4, height - 4), fill=255)
    corner = 5
    for x0, y0 in ((3, 3), (width - 4 - corner, 3), (3, height - 4 - corner), (width - 4 - corner, height - 4 - corner)):
        draw.rectangle((x0, y0, x0 + corner - 1, y0 + corner - 1), fill=0)
    button.putalpha(mask)
    return button


def main():
    approved = Image.open(CONCEPT / "mode_selection_draft_v4_story_modes.png").convert("RGB")
    background = Image.open(CONCEPT / "mode_selection_background_only.png").convert("RGB")
    if approved.size != (1280, 720) or background.size != (1280, 720):
        raise ValueError("Mode room assets must be 1280x720")

    entries = [save_sprite("spr_mode_select_bg", background)]
    manifest = {"background": "spr_mode_select_bg", "buttons": {}}
    for label, box in BUTTONS.items():
        name = f"spr_mode_select_{label}"
        entries.append(save_sprite(name, cut_button(approved, box)))
        manifest["buttons"][label] = {
            "sprite": name,
            "draft_position": [box[0], box[1]],
            "size": [box[2] - box[0], box[3] - box[1]],
        }

    project_path = ROOT / "final_project.yyp"
    project = project_path.read_text(encoding="utf-8")
    marker = '    {"id":{"name":"spr_mode_classic"'
    if marker not in project:
        raise ValueError("Could not find mode sprite entry in project")
    for entry in reversed(entries):
        name = entry.split('"name":"')[1].split('"')[0]
        if f'"name":"{name}"' not in project:
            project = project.replace(marker, entry + marker, 1)
    project_path.write_text(project, encoding="utf-8")
    (CONCEPT / "assets_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main()

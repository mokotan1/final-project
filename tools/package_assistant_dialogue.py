"""Package the approved generated assistant art as aligned GameMaker frames."""

from copy import deepcopy
from pathlib import Path
import json
import re
import sys
import uuid

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
NAME = "spr_assistant_dialogue"
FRAME_NAMES = (
    "neutral_closed",
    "neutral_talk",
    "happy_talk",
    "thoughtful_closed",
    "surprised_talk",
    "reassuring_talk",
)
CELL = (342, 768)


def read_gm_json(path):
    return json.loads(re.sub(r",\s*([}\]])", r"\1", path.read_text(encoding="utf-8")))


def main(source):
    image = Image.open(source).convert("RGBA")
    if image.size != (1024, 1536):
        raise ValueError(f"Expected a 1024x1536 image, got {image.size}")

    target = ROOT / "sprites" / NAME
    target.mkdir(parents=True, exist_ok=True)
    frames_dir = target / "frames"
    frames_dir.mkdir(exist_ok=True)
    sheet = Image.new("RGBA", (CELL[0] * 3, CELL[1] * 2))
    ids = []
    for index, label in enumerate(FRAME_NAMES):
        col, row = index % 3, index // 3
        left, right = ((0, 341), (341, 683), (683, 1024))[col]
        top, bottom = ((0, 750), (750, 1536))[row]
        cell = image.crop((left, top, right, bottom))
        # Keep opaque pixel clusters and discard the faint generated backdrop.
        alpha = cell.getchannel("A").point(lambda value: 255 if value >= 128 else 0)
        cell.putalpha(alpha)
        bounds = alpha.getbbox()
        if bounds is None:
            raise ValueError(f"Empty frame: {label}")
        body = cell.crop(bounds)
        frame = Image.new("RGBA", CELL)
        x = (CELL[0] - body.width) // 2
        y = 10
        frame.alpha_composite(body, (x, y))
        frame_id = str(uuid.uuid5(uuid.NAMESPACE_URL, f"{NAME}/{label}"))
        ids.append(frame_id)
        frame.save(target / f"{frame_id}.png")
        frame.save(frames_dir / f"{frame_id}.png")
        sheet.alpha_composite(frame, (col * CELL[0], row * CELL[1]))

    sheet.save(target / f"{NAME}_sheet.png")

    source_yy = read_gm_json(ROOT / "sprites" / "spr_assistant_pixel" / "spr_assistant_pixel.yy")
    template_frame = source_yy["frames"][0]
    template_key = source_yy["sequence"]["tracks"][0]["keyframes"]["Keyframes"][0]
    source_yy["%Name"] = source_yy["name"] = NAME
    source_yy["width"], source_yy["height"] = CELL
    source_yy["bbox_left"] = 0
    source_yy["bbox_right"] = CELL[0] - 1
    source_yy["bbox_top"] = 0
    source_yy["bbox_bottom"] = CELL[1] - 1
    source_yy["frames"] = []
    source_yy["sequence"]["%Name"] = source_yy["sequence"]["name"] = NAME
    source_yy["sequence"]["length"] = float(len(ids))
    source_yy["sequence"]["playbackSpeed"] = 0.0
    source_yy["sequence"]["xorigin"] = CELL[0] // 2
    source_yy["sequence"]["yorigin"] = CELL[1]
    keys = []
    for index, frame_id in enumerate(ids):
        frame_meta = deepcopy(template_frame)
        frame_meta["%Name"] = frame_meta["name"] = frame_id
        source_yy["frames"].append(frame_meta)
        key = deepcopy(template_key)
        key["Channels"]["0"]["Id"] = {
            "name": frame_id,
            "path": f"sprites/{NAME}/{NAME}.yy",
        }
        key["id"] = str(uuid.uuid5(uuid.NAMESPACE_URL, f"{NAME}/key/{index}"))
        key["Key"] = float(index)
        keys.append(key)
    source_yy["sequence"]["tracks"][0]["keyframes"]["Keyframes"] = keys
    layer_id = source_yy["layers"][0]["name"]
    layer_dir = target / "layers" / layer_id
    layer_dir.mkdir(parents=True, exist_ok=True)
    for frame_id in ids:
        (layer_dir / f"{frame_id}.png").write_bytes((target / f"{frame_id}.png").read_bytes())
    (target / f"{NAME}.yy").write_text(json.dumps(source_yy, indent=2) + "\n", encoding="utf-8")

    project_path = ROOT / "final_project.yyp"
    project = project_path.read_text(encoding="utf-8")
    resource_line = f'    {{"id":{{"name":"{NAME}","path":"sprites/{NAME}/{NAME}.yy",}},}},\n'
    if f'"name":"{NAME}"' not in project:
        marker = '    {"id":{"name":"spr_assistant_pixel"'
        project = project.replace(marker, resource_line + marker, 1)
        project_path.write_text(project, encoding="utf-8")

    manifest = {
        "sprite": NAME,
        "sheet": f"sprites/{NAME}/{NAME}_sheet.png",
        "cell_size": list(CELL),
        "grid": [3, 2],
        "frames": [{"index": i, "expression": label, "id": ids[i]} for i, label in enumerate(FRAME_NAMES)],
    }
    (target / "frames.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main(Path(sys.argv[1]))

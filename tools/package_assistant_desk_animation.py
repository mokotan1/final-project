"""Package the six generated desk poses into an aligned GameMaker animation."""

from copy import deepcopy
from pathlib import Path
import json
import re
import sys
import uuid

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
NAME = "spr_assistant_desk_talk"
LABELS = (
    "rest",
    "blink",
    "speak_rest",
    "speak_gesture",
    "smile_gesture",
    "settle",
)
DURATIONS_MS = (600, 100, 180, 330, 280, 450)
TIMELINE_FRAMES = tuple(round(milliseconds * 60 / 1000) for milliseconds in DURATIONS_MS)
CELL = 512


def read_gm_json(path):
    return json.loads(re.sub(r",\s*([}\]])", r"\1", path.read_text(encoding="utf-8")))


def main(source_path):
    source = Image.open(source_path).convert("RGBA")
    if source.size != (1536, 1024):
        raise ValueError(f"Expected a 1536x1024 sheet, got {source.size}")
    target = ROOT / "sprites" / NAME
    frames_dir = target / "frames"
    frames_dir.mkdir(parents=True, exist_ok=True)
    sheet = Image.new("RGBA", source.size)
    frame_ids = []
    frame_images = []

    for index, label in enumerate(LABELS):
        col, row = index % 3, index // 3
        frame = source.crop((col * CELL, row * CELL, (col + 1) * CELL, (row + 1) * CELL))
        # The generation sheet lets the upper row's counter bleed into the
        # first few pixels of the lower row. Clear that gutter, then make
        # alpha hard-edged like the pixel clusters in the source art.
        if row:
            frame.paste((0, 0, 0, 0), (0, 0, CELL, 17))
        frame.putalpha(frame.getchannel("A").point(lambda alpha: 255 if alpha >= 128 else 0))
        frame_id = str(uuid.uuid5(uuid.NAMESPACE_URL, f"{NAME}/{label}"))
        frame_ids.append(frame_id)
        frame_images.append(frame)
        frame.save(target / f"{frame_id}.png")
        frame.save(frames_dir / f"{frame_id}.png")
        sheet.alpha_composite(frame, (col * CELL, row * CELL))

    sheet.save(target / f"{NAME}_sheet.png")
    frame_images[0].save(
        target / f"{NAME}_preview.gif",
        save_all=True,
        append_images=frame_images[1:],
        duration=DURATIONS_MS,
        loop=0,
        disposal=2,
        transparency=0,
    )

    sprite = read_gm_json(ROOT / "sprites" / "spr_assistant_pixel" / "spr_assistant_pixel.yy")
    frame_template = sprite["frames"][0]
    key_template = sprite["sequence"]["tracks"][0]["keyframes"]["Keyframes"][0]
    sprite["%Name"] = sprite["name"] = NAME
    sprite["width"] = sprite["height"] = CELL
    sprite["bbox_left"] = sprite["bbox_top"] = 0
    sprite["bbox_right"] = sprite["bbox_bottom"] = CELL - 1
    sprite["frames"] = []
    sequence = sprite["sequence"]
    sequence["%Name"] = sequence["name"] = NAME
    sequence["length"] = float(sum(TIMELINE_FRAMES))
    sequence["playbackSpeed"] = 60.0
    sequence["xorigin"] = CELL // 2
    sequence["yorigin"] = CELL
    keys = []
    timeline_position = 0
    for index, frame_id in enumerate(frame_ids):
        frame_meta = deepcopy(frame_template)
        frame_meta["%Name"] = frame_meta["name"] = frame_id
        sprite["frames"].append(frame_meta)
        key = deepcopy(key_template)
        key["Channels"]["0"]["Id"] = {
            "name": frame_id,
            "path": f"sprites/{NAME}/{NAME}.yy",
        }
        key["id"] = str(uuid.uuid5(uuid.NAMESPACE_URL, f"{NAME}/key/{index}"))
        key["Key"] = float(timeline_position)
        key["Length"] = float(TIMELINE_FRAMES[index])
        timeline_position += TIMELINE_FRAMES[index]
        keys.append(key)
    sequence["tracks"][0]["keyframes"]["Keyframes"] = keys
    layer_id = sprite["layers"][0]["name"]
    layer_dir = target / "layers" / layer_id
    layer_dir.mkdir(parents=True, exist_ok=True)
    for frame_id in frame_ids:
        (layer_dir / f"{frame_id}.png").write_bytes((target / f"{frame_id}.png").read_bytes())
    (target / f"{NAME}.yy").write_text(json.dumps(sprite, indent=2) + "\n", encoding="utf-8")

    project_path = ROOT / "final_project.yyp"
    project = project_path.read_text(encoding="utf-8")
    if f'"name":"{NAME}"' not in project:
        marker = '    {"id":{"name":"spr_assistant_dialogue"'
        line = f'    {{"id":{{"name":"{NAME}","path":"sprites/{NAME}/{NAME}.yy",}},}},\n'
        if marker not in project:
            raise ValueError("Could not find assistant sprite entry in project")
        project_path.write_text(project.replace(marker, line + marker, 1), encoding="utf-8")

    manifest = {
        "sprite": NAME,
        "sheet": f"sprites/{NAME}/{NAME}_sheet.png",
        "cell_size": [CELL, CELL],
        "grid": [3, 2],
        "preview_timing_ms": list(DURATIONS_MS),
        "frames": [
            {"index": index, "pose": label, "id": frame_ids[index]}
            for index, label in enumerate(LABELS)
        ],
    }
    (target / "frames.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main(Path(sys.argv[1]))

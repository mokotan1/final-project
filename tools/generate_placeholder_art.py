"""Generate the original placeholder art used by the GameMaker prototype.

Run from the project root with: python tools/generate_placeholder_art.py
"""
from pathlib import Path
from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]

SPRITES = {
    "spr_table": ((960, 520), "table"),
    "spr_ball_player": ((36, 36), "ball_player"),
    "spr_ball_target": ((36, 36), "ball_target"),
    "spr_ball_foul": ((36, 36), "ball_foul"),
    "spr_cue": ((220, 16), "cue"),
    "spr_cushion": ((64, 32), "cushion"),
    "spr_inventory_slot": ((76, 76), "slot"),
    "spr_item_move": ((52, 52), "move"),
    "spr_item_remove": ((52, 52), "remove"),
}

FRAME_IDS = {
    "spr_table": ("2840c51b-21d4-44e0-aeed-8cc6889a6b01", "15fd28e9-f95c-407a-a5a9-6052df670101"),
    "spr_ball_player": ("2840c51b-21d4-44e0-aeed-8cc6889a6b02", "15fd28e9-f95c-407a-a5a9-6052df670102"),
    "spr_ball_target": ("2840c51b-21d4-44e0-aeed-8cc6889a6b03", "15fd28e9-f95c-407a-a5a9-6052df670103"),
    "spr_ball_foul": ("2840c51b-21d4-44e0-aeed-8cc6889a6b04", "15fd28e9-f95c-407a-a5a9-6052df670104"),
    "spr_cue": ("2840c51b-21d4-44e0-aeed-8cc6889a6b05", "15fd28e9-f95c-407a-a5a9-6052df670105"),
    "spr_cushion": ("2840c51b-21d4-44e0-aeed-8cc6889a6b06", "15fd28e9-f95c-407a-a5a9-6052df670106"),
    "spr_inventory_slot": ("2840c51b-21d4-44e0-aeed-8cc6889a6b07", "15fd28e9-f95c-407a-a5a9-6052df670107"),
    "spr_item_move": ("2840c51b-21d4-44e0-aeed-8cc6889a6b08", "15fd28e9-f95c-407a-a5a9-6052df670108"),
    "spr_item_remove": ("2840c51b-21d4-44e0-aeed-8cc6889a6b10", "15fd28e9-f95c-407a-a5a9-6052df670110"),
}


def sprite_yy(name, size, frame_id, layer_id):
    w, h = size
    centered = name not in ("spr_table", "spr_cue")
    origin = 4 if centered else (3 if name == "spr_cue" else 0)
    xorigin = w // 2 if centered else 0
    yorigin = h // 2 if centered or name == "spr_cue" else 0
    collision_kind = 1 if name.startswith("spr_ball_") else 0
    return f'''{{
  "$GMSprite":"v2",
  "%Name":"{name}",
  "bboxMode":0,
  "bbox_bottom":{h - 1},
  "bbox_left":0,
  "bbox_right":{w - 1},
  "bbox_top":0,
  "collisionKind":{collision_kind},
  "collisionTolerance":0,
  "DynamicTexturePage":false,
  "edgeFiltering":false,
  "For3D":false,
  "frames":[
    {{"$GMSpriteFrame":"","%Name":"{frame_id}","name":"{frame_id}","resourceType":"GMSpriteFrame","resourceVersion":"2.0",}},
  ],
  "gridX":0,
  "gridY":0,
  "height":{h},
  "HTile":false,
  "layers":[
    {{"$GMImageLayer":"","%Name":"{layer_id}","blendMode":0,"displayName":"default","isLocked":false,"name":"{layer_id}","opacity":100.0,"resourceType":"GMImageLayer","resourceVersion":"2.0","visible":true,}},
  ],
  "name":"{name}",
  "nineSlice":null,
  "origin":{origin},
  "parent":{{"name":"final_project","path":"final_project.yyp",}},
  "preMultiplyAlpha":false,
  "resourceType":"GMSprite",
  "resourceVersion":"2.0",
  "sequence":{{
    "$GMSequence":"v1",
    "%Name":"{name}",
    "autoRecord":true,
    "backdropHeight":768,
    "backdropImageOpacity":0.5,
    "backdropImagePath":"",
    "backdropWidth":1366,
    "backdropXOffset":0.0,
    "backdropYOffset":0.0,
    "events":{{"$KeyframeStore<MessageEventKeyframe>":"","Keyframes":[],"resourceType":"KeyframeStore<MessageEventKeyframe>","resourceVersion":"2.0",}},
    "eventStubScript":null,
    "eventToFunction":{{}},
    "length":1.0,
    "lockOrigin":false,
    "moments":{{"$KeyframeStore<MomentsEventKeyframe>":"","Keyframes":[],"resourceType":"KeyframeStore<MomentsEventKeyframe>","resourceVersion":"2.0",}},
    "name":"{name}",
    "playback":1,
    "playbackSpeed":30.0,
    "playbackSpeedType":0,
    "resourceType":"GMSequence",
    "resourceVersion":"2.0",
    "showBackdrop":true,
    "showBackdropImage":false,
    "timeUnits":1,
    "tracks":[
      {{"$GMSpriteFramesTrack":"","builtinName":0,"events":[],"inheritsTrackColour":true,"interpolation":1,"isCreationTrack":false,"keyframes":{{"$KeyframeStore<SpriteFrameKeyframe>":"","Keyframes":[{{"$Keyframe<SpriteFrameKeyframe>":"","Channels":{{"0":{{"$SpriteFrameKeyframe":"","Id":{{"name":"{frame_id}","path":"sprites/{name}/{name}.yy",}},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",}},}},"Disabled":false,"id":"963f95d3-4b26-4a6a-a5b5-{frame_id[-12:]}","IsCreationKey":false,"Key":0.0,"Length":1.0,"Stretch":false,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0",}}],"resourceType":"KeyframeStore<SpriteFrameKeyframe>","resourceVersion":"2.0",}},"modifiers":[],"name":"frames","resourceType":"GMSpriteFramesTrack","resourceVersion":"2.0","spriteId":null,"trackColour":0,"tracks":[],"traits":0,}},
    ],
    "visibleRange":null,
    "volume":1.0,
    "xorigin":{xorigin},
    "yorigin":{yorigin},
  }},
  "swatchColours":null,
  "swfPrecision":2.525,
  "textureGroupId":{{"name":"Default","path":"texturegroups/Default",}},
  "type":0,
  "VTile":false,
  "width":{w},
}}'''


def draw_art(size, kind):
    image = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(image)
    w, h = size
    if kind == "table":
        d.rounded_rectangle((0, 0, w - 1, h - 1), radius=34, fill="#44281b", outline="#d5a855", width=5)
        d.rounded_rectangle((22, 22, w - 23, h - 23), radius=24, fill="#104f3a", outline="#071d16", width=12)
        d.rounded_rectangle((50, 50, w - 51, h - 51), radius=10, fill="#177c5a", outline="#0d4935", width=4)
        for x in range(120, w - 80, 120):
            d.ellipse((x, 12, x + 5, 17), fill="#f0d38a")
            d.ellipse((x, h - 18, x + 5, h - 13), fill="#f0d38a")
    elif kind.startswith("ball"):
        colors = {"ball_player": "#e84b4b", "ball_target": "#ffd84b", "ball_foul": "#f6f5eb"}
        d.ellipse((1, 1, w - 2, h - 2), fill=colors[kind], outline="#151a1b", width=2)
        d.ellipse((7, 5, 14, 12), fill=(255, 255, 255, 150))
        if kind == "ball_player":
            d.text((w // 2, h // 2), "P", anchor="mm", fill="white", stroke_width=1, stroke_fill="#7b1e1e")
        elif kind == "ball_foul":
            d.text((w // 2, h // 2), "!", anchor="mm", fill="#d23b3b")
    elif kind == "cue":
        d.rounded_rectangle((2, 4, w - 3, h - 5), radius=4, fill="#d8aa65", outline="#58351f", width=2)
        d.rectangle((2, 4, 16, h - 5), fill="#3d75a8")
        d.rectangle((w - 46, 4, w - 3, h - 5), fill="#7b4028")
    elif kind == "cushion":
        d.rounded_rectangle((0, 0, w - 1, h - 1), radius=8, fill="#135f45", outline="#d5a855", width=3)
    elif kind == "slot":
        d.rounded_rectangle((2, 2, w - 3, h - 3), radius=13, fill="#17252a", outline="#d5a855", width=3)
        d.rounded_rectangle((9, 9, w - 10, h - 10), radius=9, outline="#53696d", width=2)
    elif kind == "move":
        d.ellipse((6, 6, w - 7, h - 7), fill="#43b0f1")
        d.line((w // 2, 13, w // 2, h - 14), fill="white", width=5)
        d.line((13, h // 2, w - 14, h // 2), fill="white", width=5)
        for p in (((w // 2, 8), (w // 2 - 6, 16), (w // 2 + 6, 16)), ((w // 2, h - 9), (w // 2 - 6, h - 17), (w // 2 + 6, h - 17)), ((8, h // 2), (16, h // 2 - 6), (16, h // 2 + 6)), ((w - 9, h // 2), (w - 17, h // 2 - 6), (w - 17, h // 2 + 6))):
            d.polygon(p, fill="white")
    elif kind == "remove":
        d.ellipse((6, 6, w - 7, h - 7), fill="#ef765e")
        d.line((16, 16, w - 17, h - 17), fill="white", width=7)
        d.line((w - 17, 16, 16, h - 17), fill="white", width=7)
    return image


def main():
    for name, (size, kind) in SPRITES.items():
        frame_id, layer_id = FRAME_IDS[name]
        image = draw_art(size, kind)
        root = ROOT / "sprites" / name
        (root / "layers" / layer_id).mkdir(parents=True, exist_ok=True)
        (root / "frames").mkdir(parents=True, exist_ok=True)
        image.save(root / "layers" / layer_id / f"{frame_id}.png")
        image.save(root / "frames" / f"{frame_id}.png")
        image.save(root / f"{frame_id}.png")
        (root / f"{name}.yy").write_text(sprite_yy(name, size, frame_id, layer_id), encoding="utf-8")


if __name__ == "__main__":
    main()

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "sprites" / "spr_ui_pixel_font"
OUT.mkdir(parents=True, exist_ok=True)
(OUT / "frames").mkdir(exist_ok=True)
(OUT / "layers").mkdir(exist_ok=True)
layer_id = "9f8e7d6c-0001-4a11-8999-000000000001"
(OUT / "layers" / layer_id).mkdir(exist_ok=True)
font = ImageFont.load_default()
glyph_map = "".join(chr(i) for i in range(32, 127))
frame_ids = []
for index, char in enumerate(glyph_map):
    gid = f"9f8e7d6c-{index+1:04x}-4a11-8999-{index+1:012x}"
    frame_ids.append(gid)
    image = Image.new("RGBA", (8, 12), (0, 0, 0, 0))
    ImageDraw.Draw(image).text((0, 0), char, font=font, fill=(255, 255, 255, 255))
    alpha = image.getchannel("A").point(lambda p: 255 if p >= 128 else 0)
    image.putalpha(alpha)
    image.save(OUT / f"{gid}.png"); image.save(OUT / "frames" / f"{gid}.png"); image.save(OUT / "layers" / layer_id / f"{gid}.png")

frames = "\n".join(f'    {{"$GMSpriteFrame":"v1","%Name":"{gid}","name":"{gid}","resourceType":"GMSpriteFrame","resourceVersion":"2.0",}},' for gid in frame_ids)
keys = "\n".join(f'            {{"$Keyframe<SpriteFrameKeyframe>":"","Channels":{{"0":{{"$SpriteFrameKeyframe":"","Id":{{"name":"{gid}","path":"sprites/spr_ui_pixel_font/spr_ui_pixel_font.yy",}},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",}},}},"Disabled":false,"id":"{gid}","IsCreationKey":false,"Key":{i}.0,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,}},' for i, gid in enumerate(frame_ids))
yy = '{\n  "$GMSprite":"v2","%Name":"spr_ui_pixel_font","bboxMode":0,"bbox_bottom":11,"bbox_left":0,"bbox_right":7,"bbox_top":0,"collisionKind":0,"collisionTolerance":0,"DynamicTexturePage":false,"edgeFiltering":false,"For3D":false,\n  "frames":[\n' + frames + '\n  ],"gridX":0,"gridY":0,"height":12,"HTile":false,\n  "layers":[{"$GMImageLayer":"","%Name":"' + layer_id + '","blendMode":0,"displayName":"default","isLocked":false,"name":"' + layer_id + '","opacity":100.0,"resourceType":"GMImageLayer","resourceVersion":"2.0","visible":true,}],\n  "name":"spr_ui_pixel_font","nineSlice":null,"origin":0,"parent":{"name":"final_project","path":"final_project.yyp",},"preMultiplyAlpha":false,"resourceType":"GMSprite","resourceVersion":"2.0",\n  "sequence":{"$GMSequence":"v1","%Name":"spr_ui_pixel_font","autoRecord":true,"backdropHeight":768,"backdropImageOpacity":0.5,"backdropImagePath":"","backdropWidth":1366,"backdropXOffset":0.0,"backdropYOffset":0.0,"events":{"$KeyframeStore<MessageEventKeyframe>":"","Keyframes":[],"resourceType":"KeyframeStore<MessageEventKeyframe>","resourceVersion":"2.0",},"eventStubScript":null,"eventToFunction":{},"length":95.0,"lockOrigin":false,"moments":{"$KeyframeStore<MomentsEventKeyframe>":"","Keyframes":[],"resourceType":"KeyframeStore<MomentsEventKeyframe>","resourceVersion":"2.0",},"name":"spr_ui_pixel_font","playback":1,"playbackSpeed":30.0,"playbackSpeedType":0,"resourceType":"GMSequence","resourceVersion":"2.0","showBackdrop":false,"showBackdropImage":false,"timeUnits":1,"tracks":[{"$GMSpriteFramesTrack":"","builtinName":0,"events":[],"inheritsTrackColour":true,"interpolation":1,"keyframes":{"$KeyframeStore<SpriteFrameKeyframe>":"","Keyframes":[\n' + keys + '\n          ],"resourceType":"KeyframeStore<SpriteFrameKeyframe>","resourceVersion":"2.0",},"modifiers":[],"name":"frames","resourceType":"GMSpriteFramesTrack","resourceVersion":"2.0","spriteId":null,"trackColour":0,"tracks":[],"traits":0,}],"visibleRange":null,"volume":1.0,"xorigin":0,"yorigin":0,},"swatchColours":null,"swfPrecision":2.525,"textureGroupId":{"name":"Default","path":"texturegroups/Default",},"type":0,"VTile":false,"width":8\n}\n'
(OUT / "spr_ui_pixel_font.yy").write_text(yy, encoding="utf-8")

"""Generate an editable 8x12 Korean bitmap sprite font."""
from pathlib import Path
import re
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "sprites" / "spr_ui_pixel_font_ko"
for p in (OUT, OUT / "frames", OUT / "layers"):
    p.mkdir(parents=True, exist_ok=True)
layer = "4ab2f7c1-0001-4a11-8999-000000000001"
(OUT / "layers" / layer).mkdir(exist_ok=True)
ascii_chars = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
korean = "클래식무한공이동위험샷파울제거알수없음설정언어한국어영어켜짐꺼짐완료재개메인메뉴기회점수최고기록간격아이템선택보상소유인벤토리공놓기배율새기록게임오버최종점수플레이하세요빈곳에다음은쿠션마다입니다하나를제거합니다테이블을클릭해놓으세요준비하기전에사용하세요있을때"
# Include every Hangul syllable used by the current UI strings. This also
# keeps newly translated tooltips from silently rendering missing glyphs.
sources = sorted((ROOT / "objects").rglob("*.gml")) + sorted((ROOT / "scripts").rglob("*.gml"))
korean = "".join(dict.fromkeys(korean + "".join(
    ch for path in sources for ch in re.findall(r"[가-힣]", path.read_text(encoding="utf-8"))
)))
# Rebuild the Hangul set from code points so this tool remains UTF-8/locale
# independent even when run from a legacy Windows shell.
korean = "".join(dict.fromkeys(korean + "".join(chr(n) for n in [0xd074,0xb798,0xc2dd,0xbb34,0xd55c,0xacf5,0xc774,0xb3d9,0xc704,0xd5d8,0xc0f7,0xd30c,0xc6b8,0xc81c,0xac70,0xc54c,0xc218,0xc5c6,0xc124,0xc815,0xc5b8,0xc5b4,0xad6d,0xc601,0xcf1c,0xc9d0,0xaebc,0xc644,0xb8cc,0xc7ac,0xac1c,0xba54,0xc778,0xb274,0xae30,0xd68c,0xc810,0xcd5c,0xace0,0xb85d,0xac04,0xaca9,0xc544,0xd15c,0xc120,0xd0dd,0xbcf4,0xc0c1,0xc18c,0xc720,0xbca4,0xd1a0,0xb9ac,0xb193,0xbc30,0xc728,0xc0c8,0xac8c,0xc784,0xc624,0xbc84,0xc885,0xd50c,0xb808,0xd558,0xc138,0xc694,0xbe48,0xacf3,0xb2e4,0xc740,0xcfe0,0xc158,0xb9c8,0xc785,0xb2c8,0xb098,0xb97c,0xd569,0xd14c,0xbe14,0xc744,0xb9ad,0xd574,0xc73c,0xc900,0xbe44,0xc804,0xc5d0,0xc0ac,0xc6a9,0xc788,0xb54c,0xac01,0xb3c4,0xc758,0xc2b9,0xbd80,0xbaa8,0xb4dc,0xc21c,0xc2dc,0xc791,0xb4a4,0xb85c,0xd6a8,0xacfc,0xc800,0xc7a5,0xc2e4,0xd328,0xb9cc,0xc6cc,0xccab,0xc62e,0xcd08,0xc5ed,0xb428,0xba48,0xcd9c,0xc2b5,0xb294,0xb7c9])))
glyph_manifest = ROOT / "tools" / "korean_glyphs.txt"
# Reuse the checked-in manifest when translations gain new Hangul syllables;
# this keeps the atlas frame order identical to lang_font_init's mapping.
previous_chars = glyph_manifest.read_text(encoding="utf-8").rstrip("\r\n") if glyph_manifest.exists() else ""
# Preserve existing frame indices while adding syllables introduced by new UI.
score_digits = "０１２３４５６７８９"
chars = "".join(dict.fromkeys(previous_chars + ascii_chars + korean + score_digits))
if not chars.startswith(ascii_chars):
    raise ValueError("The font manifest must begin with the 95 ASCII glyphs")
font = ImageFont.truetype(r"C:\Windows\Fonts\malgun.ttf", 11)
ids = []
atlas_columns = 16
# Two transparent pixels on every side prevent neighboring glyphs from
# leaking into draw_sprite_part_ext samples on scaled texture pages.
atlas = Image.new("RGBA", (atlas_columns * 16, ((len(chars) + atlas_columns - 1) // atlas_columns) * 18), (0, 0, 0, 0))
for i, ch in enumerate(chars):
    gid = f"4ab2f7c1-{i+1:04x}-4a11-8999-{i+1:012x}"
    ids.append(gid)
    # Keep the shipped English pixel atlas unchanged. Malgun's antialiasing
    # does not match the existing 8x12 Latin glyphs and makes them look broken.
    old_id = f"9f8e7d6c-{i+1:04x}-4a11-8999-{i+1:012x}"
    old_path = ROOT / "sprites" / "spr_ui_pixel_font" / "frames" / f"{old_id}.png"
    if ord(ch) < 127 and old_path.exists():
        im = Image.open(old_path).convert("RGBA")
    else:
        im = Image.new("RGBA", (12, 14), (0, 0, 0, 0))
        d = ImageDraw.Draw(im); box = d.textbbox((0, 0), ch, font=font)
        d.text(((12-(box[2]-box[0]))//2-box[0], (14-(box[3]-box[1]))//2-box[1]), ch, font=font, fill=(255,255,255,255))
        im.putalpha(im.getchannel("A").point(lambda p: 255 if p >= 100 else 0))
    # Keep a real RGBA alpha channel and fail early if a non-space glyph is
    # accidentally exported empty; Igor then imports the same pixels reliably.
    if ch not in (" ", "`", "_", "|") and im.getchannel("A").getbbox() is None:
        raise RuntimeError(f"empty glyph export: U+{ord(ch):04X}")
    atlas.paste(im, ((i % atlas_columns) * 16 + 2, (i // atlas_columns) * 18 + 2))
    for target in (OUT / f"{gid}.png", OUT / "frames" / f"{gid}.png", OUT / "layers" / layer / f"{gid}.png"):
        im.save(target, format="PNG", optimize=False, compress_level=0)
atlas_out = ROOT / "sprites" / "spr_ui_glyph_atlas"
atlas_frame = "7d510a71-0001-4a11-8999-000000000001"
atlas_layer = "7d510a71-0002-4a11-8999-000000000002"
for target in (atlas_out / f"{atlas_frame}.png", atlas_out / "frames" / f"{atlas_frame}.png", atlas_out / "layers" / atlas_layer / f"{atlas_frame}.png"):
    target.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(target, format="PNG", optimize=False, compress_level=0)
template = (ROOT / "sprites" / "spr_inventory_slot" / "spr_inventory_slot.yy").read_text(encoding="utf-8")
atlas_yy = (template.replace("spr_inventory_slot", "spr_ui_glyph_atlas")
    .replace("2840c51b-21d4-44e0-aeed-8cc6889a6b07", atlas_frame)
    .replace("15fd28e9-f95c-407a-a5a9-6052df670107", atlas_layer)
    .replace("963f95d3-4b26-4a6a-a5b5-8cc6889a6b07", "7d510a71-0003-4a11-8999-000000000003")
    .replace('"bbox_bottom":75', f'"bbox_bottom":{atlas.height - 1}')
    .replace('"bbox_right":75', f'"bbox_right":{atlas.width - 1}')
    .replace('"height":76', f'"height":{atlas.height}')
    .replace('"width":76', f'"width":{atlas.width}')
    .replace('"origin":4', '"origin":0')
    .replace('"xorigin":38', '"xorigin":0')
    .replace('"yorigin":38', '"yorigin":0'))
(atlas_out / "spr_ui_glyph_atlas.yy").write_text(atlas_yy, encoding="utf-8")
frames = "\n".join(f'    {{"$GMSpriteFrame":"v1","%Name":"{g}","name":"{g}","resourceType":"GMSpriteFrame","resourceVersion":"2.0",}},' for g in ids)
keys = "\n".join(f'            {{"$Keyframe<SpriteFrameKeyframe>":"","Channels":{{"0":{{"$SpriteFrameKeyframe":"","Id":{{"name":"{g}","path":"sprites/spr_ui_pixel_font_ko/spr_ui_pixel_font_ko.yy",}},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",}},}},"Disabled":false,"id":"{g}","IsCreationKey":false,"Key":{i}.0,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,}},' for i,g in enumerate(ids))
yy = '{\n  "$GMSprite":"v2","%Name":"spr_ui_pixel_font_ko","bboxMode":0,"bbox_bottom":11,"bbox_left":0,"bbox_right":7,"bbox_top":0,"collisionKind":0,"collisionTolerance":0,"DynamicTexturePage":false,"edgeFiltering":false,"For3D":false,\n  "frames":[\n'+frames+'\n  ],"gridX":0,"height":12,"HTile":false,\n  "layers":[{"$GMImageLayer":"","%Name":"'+layer+'","blendMode":0,"displayName":"default","isLocked":false,"name":"'+layer+'","opacity":100.0,"resourceType":"GMImageLayer","resourceVersion":"2.0","visible":true,}],\n  "name":"spr_ui_pixel_font_ko","origin":0,"parent":{"name":"final_project","path":"final_project.yyp",},"preMultiplyAlpha":false,"resourceType":"GMSprite","resourceVersion":"2.0",\n  "sequence":{"$GMSequence":"v1","%Name":"spr_ui_pixel_font_ko","autoRecord":true,"length":'+str(len(ids))+'.0,"name":"spr_ui_pixel_font_ko","playback":1,"playbackSpeed":30.0,"playbackSpeedType":0,"resourceType":"GMSequence","resourceVersion":"2.0","tracks":[{"$GMSpriteFramesTrack":"","builtinName":0,"events":[],"inheritsTrackColour":true,"interpolation":1,"keyframes":{"$KeyframeStore<SpriteFrameKeyframe>":"","Keyframes":[\n'+keys+'\n          ],"resourceType":"KeyframeStore<SpriteFrameKeyframe>","resourceVersion":"2.0",},"modifiers":[],"name":"frames","resourceType":"GMSpriteFramesTrack","resourceVersion":"2.0","spriteId":null,"tracks":[],"traits":0,}],"volume":1.0,"xorigin":0,"yorigin":0,},"textureGroupId":{"name":"Default","path":"texturegroups/Default",},"type":0,"VTile":false,"width":8\n}\n'
yy = yy.replace('"gridX":0,"height"', '"gridX":0,"gridY":0,"height"')
yy = yy.replace('"name":"spr_ui_pixel_font_ko","origin"', '"name":"spr_ui_pixel_font_ko","nineSlice":null,"origin"')
yy = yy.replace('"autoRecord":true,"length"', '"autoRecord":true,"backdropHeight":768,"backdropImageOpacity":0.5,"backdropImagePath":"","backdropWidth":1366,"backdropXOffset":0.0,"backdropYOffset":0.0,"events":{"$KeyframeStore<MessageEventKeyframe>":"","Keyframes":[],"resourceType":"KeyframeStore<MessageEventKeyframe>","resourceVersion":"2.0",},"eventStubScript":null,"eventToFunction":{},"length"')
yy = yy.replace('"length":'+str(len(ids))+'.0,"name"', '"length":'+str(len(ids))+'.0,"lockOrigin":false,"moments":{"$KeyframeStore<MomentsEventKeyframe>":"","Keyframes":[],"resourceType":"KeyframeStore<MomentsEventKeyframe>","resourceVersion":"2.0",},"name"')
yy = yy.replace('"playbackSpeedType":0,"resourceType":"GMSequence"', '"playbackSpeedType":0,"resourceType":"GMSequence","showBackdrop":false,"showBackdropImage":false,"timeUnits":1')
yy = yy.replace('"resourceType":"GMSequence","showBackdrop":false,"showBackdropImage":false,"timeUnits":1,"resourceVersion":"2.0"', '"resourceType":"GMSequence","resourceVersion":"2.0","showBackdrop":false,"showBackdropImage":false,"timeUnits":1')
yy = yy.replace('"inheritsTrackColour":true,"interpolation":1,"keyframes"', '"inheritsTrackColour":true,"interpolation":1,"isCreationTrack":false,"keyframes"')
yy = yy.replace('"name":"frames","resourceType":"GMSpriteFramesTrack"', '"name":"frames","resourceType":"GMSpriteFramesTrack","trackColour":0')
yy = yy.replace('"trackColour":0,"tracks"', '"trackColour":0,"tracks"')
yy = yy.replace('"traits":0,}]', '"traits":0,}],"visibleRange":null,"volume":1.0,"xorigin":0,"yorigin":0,')
yy = yy.replace('"textureGroupId"', '"swatchColours":null,"swfPrecision":2.525,"textureGroupId"')
yy = yy.replace(',,"volume"', ',"volume"')
yy = yy.replace('"visibleRange":null,"volume":1.0,"xorigin":0,"yorigin":0,"volume":1.0,"xorigin":0,"yorigin":0,}', '"visibleRange":null,"volume":1.0,"xorigin":0,"yorigin":0,}')
(OUT / "spr_ui_pixel_font_ko.yy").write_text(yy, encoding="utf-8")
(ROOT / "tools" / "korean_glyphs.txt").write_text(chars, encoding="utf-8")
# Keep the runtime sprite-font map in exactly the same frame order.
localization = ROOT / "scripts" / "scr_localization" / "scr_localization.gml"
lines = localization.read_text(encoding="utf-8").splitlines(keepends=True)
for index, line in enumerate(lines):
    if "global.ui_pixel_font_ko = font_add_sprite_ext" in line:
        prefix, marker, tail = line.partition("}~")
        if not marker or '", false, 0);' not in tail:
            raise ValueError("Korean sprite-font map was not found")
        suffix = tail.split('", false, 0);', 1)[1]
        lines[index] = prefix + marker + chars[len(ascii_chars):] + '", false, 0);' + suffix
        break
else:
    raise ValueError("Korean sprite-font declaration was not found")
glyph_map_literal = chars.replace("\\", "\\\\").replace('"', '\\"')
for index, line in enumerate(lines):
    if 'global.ui_pixel_glyph_map = ' in line:
        lines[index] = '    if (!variable_global_exists("ui_pixel_glyph_map")) global.ui_pixel_glyph_map = "' + glyph_map_literal + '";\n'
        break
else:
    raise ValueError("Direct sprite glyph map declaration was not found")
localization.write_text("".join(lines), encoding="utf-8")
print(f"generated {len(ids)} glyphs")

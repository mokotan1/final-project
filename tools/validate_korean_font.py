"""Check the Korean sprite font's runtime mapping and visible frame pixels."""

from pathlib import Path
import re

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
manifest = (ROOT / "tools" / "korean_glyphs.txt").read_text(encoding="utf-8")
font_line = next(
    line for line in (ROOT / "scripts" / "scr_localization" / "scr_localization.gml")
    .read_text(encoding="utf-8").splitlines()
    if "global.ui_pixel_font_ko = font_add_sprite_ext" in line
)
hangul_map = font_line.split("}~", 1)[1].split('"', 1)[0]
assert len(manifest) >= 95 and manifest[95:] == hangul_map, "sprite frames and runtime glyph map differ"
direct_line = next(
    line for line in (ROOT / "scripts" / "scr_localization" / "scr_localization.gml")
    .read_text(encoding="utf-8").splitlines()
    if "global.ui_pixel_glyph_map = " in line
)
assert direct_line.split("}~", 1)[1].split('"', 1)[0] == manifest[95:], "direct sprite map differs"

sprite_dir = ROOT / "sprites" / "spr_ui_pixel_font_ko"
sprite_meta = (sprite_dir / "spr_ui_pixel_font_ko.yy").read_text(encoding="utf-8")
assert sprite_meta.count('"$GMSpriteFrame":"v1"') == len(manifest), "sprite frame count differs"

for index, char in enumerate(manifest, 1):
    glyph_id = f"4ab2f7c1-{index:04x}-4a11-8999-{index:012x}"
    image = Image.open(sprite_dir / "frames" / f"{glyph_id}.png")
    expected_size = (8, 12) if ord(char) < 127 else (12, 14)
    assert image.mode == "RGBA" and image.size == expected_size, f"invalid glyph image: {glyph_id}"
    if char not in (" ", "`", "_", "|"):
        assert image.getchannel("A").getbbox() is not None, f"invisible glyph: {glyph_id}"
    if index == 1:
        atlas = Image.open(ROOT / "sprites" / "spr_ui_glyph_atlas" / "7d510a71-0001-4a11-8999-000000000001.png")
        assert atlas.mode == "RGBA" and atlas.size == (256, ((len(manifest) + 15) // 16) * 18)
    left = ((index - 1) % 16) * 16 + 2
    top = ((index - 1) // 16) * 18 + 2
    assert atlas.crop((left, top, left + expected_size[0], top + expected_size[1])).tobytes() == image.tobytes(), f"atlas glyph differs: {glyph_id}"
    assert atlas.getpixel((left - 1, top - 1))[3] == 0, f"glyph gutter is not transparent: {glyph_id}"

sources = list((ROOT / "objects").rglob("*.gml")) + list((ROOT / "scripts").rglob("*.gml"))
used = {char for source in sources for char in re.findall(r"[가-힣]", source.read_text(encoding="utf-8"))}
assert used.issubset(set(manifest)), "a UI Hangul syllable is absent from the font"
print(f"PASS: {len(manifest)} Korean sprite-font frames match the runtime map and have visible pixels")

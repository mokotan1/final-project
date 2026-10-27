from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
manifest = (ROOT / "tools" / "korean_glyphs.txt").read_text(encoding="utf-8")
text = (ROOT / "scripts" / "scr_localization" / "scr_localization.gml").read_text(encoding="utf-8")
match = re.search(r'global\.ui_pixel_glyph_map = "((?:\\.|[^"\\])*)"', text)
assert match, "glyph map string not found"
glyph_map = match.group(1).encode("utf-8").decode("unicode_escape")
print(len(manifest), len(glyph_map), manifest == glyph_map)
if manifest != glyph_map:
    print("tail manifest", repr(manifest[-10:]))
    print("tail map", repr(glyph_map[-10:]))

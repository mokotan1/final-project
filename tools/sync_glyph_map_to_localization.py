from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
chars = (ROOT / "tools" / "korean_glyphs.txt").read_text(encoding="utf-8")
literal = chars.replace("\\", "\\\\").replace('"', '\\"')
path = ROOT / "scripts" / "scr_localization" / "scr_localization.gml"
lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
for index, line in enumerate(lines):
    if "global.ui_pixel_glyph_map = " in line:
        lines[index] = (
            '    if (!variable_global_exists("ui_pixel_glyph_map")) '
            f'global.ui_pixel_glyph_map = "{literal}";\n'
        )
        break
else:
    raise SystemExit("glyph map line not found")
path.write_text("".join(lines), encoding="utf-8")
print(f"synced {len(chars)} glyphs")

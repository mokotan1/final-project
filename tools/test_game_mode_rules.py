"""Static checks for classic vs endless mode rule wiring."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
mode = (ROOT / "scripts/scr_game_mode/scr_game_mode.gml").read_text(encoding="utf-8")
rules = (ROOT / "scripts/scr_game_rules/scr_game_rules.gml").read_text(encoding="utf-8")
ui_draw = (ROOT / "objects/obj_ui/Draw_64.gml").read_text(encoding="utf-8")

assert "4 : 6" in mode and "GAME_MODE_CLASSIC" in mode, "classic foul cap must be 4 and endless 6"
assert "rules_items_enabled()" in rules and "rules_process_classic_foul_pressure" in rules
assert "rules_items_enabled()" in ui_draw
assert "rules_foul_cap()" in ui_draw

print("PASS: game mode static rule wiring")

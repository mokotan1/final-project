"""Mode/menu lifecycle checks aligned with scr_game_mode and navigation commands."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
project = (ROOT / "final_project.yyp").read_text(encoding="utf-8")
rules = (ROOT / "scripts/scr_game_rules/scr_game_rules.gml").read_text(encoding="utf-8")
application = (ROOT / "scripts/scr_application_commands/scr_application_commands.gml").read_text(encoding="utf-8")
menu_step = (ROOT / "objects/obj_menu/Step_0.gml").read_text(encoding="utf-8")
result_step = (ROOT / "objects/obj_result/Step_0.gml").read_text(encoding="utf-8")
r_key = (ROOT / "objects/obj_game/KeyPress_82.gml").read_text(encoding="utf-8")

import re
order = re.findall(r'"roomId":\{"name":"([^"]+)"', project)
assert order[:2] == ["rm_menu", "rm_game"] and "rm_result" not in order
assert "rules_process_classic_foul_pressure" in rules
assert "rules_process_progression" in rules
assert "application_start_game" in application
assert "room_goto(_game_room)" in application
assert "rules_init(true)" not in application
assert "application_start_game(menu_selected_mode)" in menu_step
assert "vk_escape" in result_step
assert "room_goto(_game_room)" not in result_step
assert "application_restart_game()" in r_key
assert "menu_hover = point_in_rectangle" in result_step
assert "menu_hover && mouse_check_button_pressed(mb_left)" in result_step
assert "_gui_h * 0.5 + 168" in result_step and "_gui_h * 0.5 + 222" in result_step
game_step = (ROOT / "objects/obj_game/Step_0.gml").read_text(encoding="utf-8")
assert 'instance_create_layer(0, 0, "Instances", obj_result)' in game_step
assert "rm_result" not in game_step
assert "instance_exists(obj_result)" in r_key
assert "rules_init" not in r_key and "application_spawn_initial_balls" not in r_key
assert "if (!rules_items_enabled())" in application

print("PASS: mode navigation and classic foul-pressure wiring")

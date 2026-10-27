"""Check that the first-launch story path is registered and resumable."""

from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[1]


def test_story_entry_resources():
    raw = (ROOT / "final_project.yyp").read_text(encoding="utf-8")
    project = json.loads(re.sub(r",\s*([}\]])", r"\1", raw))
    rooms = [node["roomId"]["name"] for node in project["RoomOrderNodes"]]
    assert rooms[0] == "rm_story_intro"
    assert "rm_story_ai_verify" in rooms
    assert (ROOT / "objects/obj_story_intro/Create_0.gml").exists()
    assert (ROOT / "objects/obj_story_intro/Draw_64.gml").exists()
    assert (ROOT / "objects/obj_story_intro/Step_0.gml").exists()


def test_story_entry_has_distinct_seen_and_completed_flags():
    source = (ROOT / "objects/obj_story_intro/Create_0.gml").read_text(encoding="utf-8")
    step = (ROOT / "objects/obj_story_intro/Step_0.gml").read_text(encoding="utf-8")
    versus = (ROOT / "scripts/scr_story_versus/scr_story_versus.gml").read_text(encoding="utf-8")
    assert "story_intro_seen" in source + step
    assert "story_first_match_done" in source + versus
    assert 'asset_get_index("rm_menu")' in source
    assert 'if (_match_done > 0 || _intro_seen > 0)' in source
    assert 'asset_get_index("rm_story_ai_verify")' not in source
    assert 'asset_get_index("rm_story_ai_verify")' in step
    menu = (ROOT / "objects/obj_menu/Step_0.gml").read_text(encoding="utf-8")
    assert "application_start_story()" in menu
    assert 'keyboard_check_pressed(ord("T"))' in menu


def test_story_mode_shows_opening_still_before_match():
    menu_create = (ROOT / "objects/obj_menu/Create_0.gml").read_text(encoding="utf-8")
    menu_step = (ROOT / "objects/obj_menu/Step_0.gml").read_text(encoding="utf-8")
    menu_draw = (ROOT / "objects/obj_menu/Draw_64.gml").read_text(encoding="utf-8")
    assert "menu_story_opening = false" in menu_create
    assert "if (menu_selected_story) menu_story_opening = true" in menu_step
    assert "else if (menu_hover_story) { menu_selected_story = true" in menu_step
    assert "draw_sprite(spr_story_opening, 0, 0, 0)" in menu_draw
    assert "keyboard_check_pressed(vk_escape)" in menu_step
    assert "mouse_check_button_pressed(mb_left)) application_start_story()" in menu_step
    image = ROOT / "sprites/spr_story_opening/spr_story_opening.png"
    assert image.read_bytes()[16:24] == bytes.fromhex("00000500000002d0")  # 1280 x 720 PNG
    intro_step = (ROOT / "objects/obj_story_intro/Step_0.gml").read_text(encoding="utf-8")
    intro_draw = (ROOT / "objects/obj_story_intro/Draw_64.gml").read_text(encoding="utf-8")
    assert "line_index <= array_length(opening_lines)" in intro_step
    assert "draw_sprite(spr_story_opening, 0, 0, 0)" in intro_draw


if __name__ == "__main__":
    test_story_entry_resources()
    test_story_entry_has_distinct_seen_and_completed_flags()
    test_story_mode_shows_opening_still_before_match()

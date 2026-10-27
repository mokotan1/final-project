"""Static checks for presentation resources when GameMaker is unavailable."""
from pathlib import Path
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SPRITES = [
    "spr_table", "spr_ball_player", "spr_ball_target", "spr_ball_foul",
    "spr_cue", "spr_cushion", "spr_inventory_slot", "spr_item_move",
    "spr_item_risk_shot", "spr_item_remove",
]
PIXEL_FONT = "spr_ui_pixel_font"
EXPECTED = {
    "spr_table": (960, 520), "spr_ball_player": (36, 36),
    "spr_ball_target": (36, 36), "spr_ball_foul": (36, 36),
    "spr_cue": (220, 16), "spr_cushion": (64, 32),
    "spr_inventory_slot": (76, 76), "spr_item_move": (52, 52),
    "spr_item_risk_shot": (52, 52), "spr_item_remove": (52, 52),
}


for name in SPRITES:
    yy = ROOT / "sprites" / name / f"{name}.yy"
    assert yy.exists(), f"missing {yy}"
    text = yy.read_text(encoding="utf-8")
    assert f'"%Name":"{name}"' in text
    frame_files = list((yy.parent / "frames").glob("*.png"))
    layer_files = list((yy.parent / "layers").glob("*/*.png"))
    root_files = list(yy.parent.glob("*.png"))
    assert len(frame_files) == len(layer_files) == 1
    assert len(root_files) == 1
    assert Image.open(frame_files[0]).size == EXPECTED[name]
    assert Image.open(layer_files[0]).size == EXPECTED[name]
    assert Image.open(root_files[0]).size == EXPECTED[name]

# The HUD uses a real sprite font so runtime text does not fall back to the
# tiny default GameMaker bitmap font. Frames are printable ASCII (32..126),
# matching the map passed to font_add_sprite_ext.
font_root = ROOT / "sprites" / PIXEL_FONT
font_yy = font_root / f"{PIXEL_FONT}.yy"
assert font_yy.exists(), f"missing {font_yy}"
font_text = font_yy.read_text(encoding="utf-8")
assert '"length":95.0' in font_text
font_frames = list((font_root / "frames").glob("*.png"))
font_layers = list((font_root / "layers").glob("*/*.png"))
font_roots = list(font_root.glob("*.png"))
assert len(font_frames) == len(font_layers) == len(font_roots) == 95
assert all(Image.open(path).size == (8, 12) for path in font_frames)

for name, events in (("obj_ui", ("Create_0.gml", "Step_0.gml", "Draw_64.gml")),
                     ("obj_menu", ("Create_0.gml", "Step_0.gml", "Draw_64.gml")),
                     ("obj_result", ("Create_0.gml", "Step_0.gml", "Draw_64.gml"))):
    root = ROOT / "objects" / name
    assert (root / f"{name}.yy").exists()
    for event in events:
        assert (root / event).exists(), f"missing {root / event}"

for room_name, object_name in (("rm_menu", "obj_menu"), ("rm_game", "obj_game")):
    room = (ROOT / "rooms" / room_name / f"{room_name}.yy").read_text(encoding="utf-8")
    assert '"Width":1280' in room and '"Height":720' in room
    assert f'"name":"{object_name}"' in room
ui_step = (ROOT / "objects" / "obj_ui" / "Step_0.gml").read_text(encoding="utf-8")
assert "application_use_inventory_item(_ready_index)" in ui_step
assert "ui_inventory_page" in ui_step
result_step = (ROOT / "objects" / "obj_result" / "Step_0.gml").read_text(encoding="utf-8")
assert "application_restart_game()" in result_step
assert "application_go_to_main_menu()" in result_step
menu_step = (ROOT / "objects" / "obj_menu" / "Step_0.gml").read_text(encoding="utf-8")
assert "application_start_game(menu_selected_mode)" in menu_step

ui_draw = (ROOT / "objects" / "obj_ui" / "Draw_64.gml").read_text(encoding="utf-8")
ui_create = (ROOT / "objects" / "obj_ui" / "Create_0.gml").read_text(encoding="utf-8")
result_draw = (ROOT / "objects" / "obj_result" / "Draw_64.gml").read_text(encoding="utf-8")
rules_source = (ROOT / "scripts" / "scr_game_rules" / "scr_game_rules.gml").read_text(encoding="utf-8")
localization = (ROOT / "scripts" / "scr_localization" / "scr_localization.gml").read_text(encoding="utf-8")
assert "lang_font_init()" in ui_create
assert "pixel_draw_text" in ui_draw
assert "font_add_sprite_ext" not in localization
assert "draw_set_font(-1)" not in ui_draw and "draw_set_font(-1)" not in result_draw
assert "fnt_ui" not in ui_draw and "fnt_ui" not in result_draw
# Cushion callouts use the pixel font at readable size and live for 84 frames
# (0.5s hold plus a fade), without changing score/rule calculations.
assert "life: 84" in rules_source
assert "var _text_hold = 30;" in ui_draw
assert "var _label_scale = 3;" in ui_draw

print(f"PASS: {len(SPRITES)} sprites + {PIXEL_FONT} (95 frames), 3 UI objects, and in-game result overlay passed static checks")

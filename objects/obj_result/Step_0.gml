var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _result_cx = _gui_w * 0.5;
var _result_cy = _gui_h * 0.5;
var _play_btn = ui_result_play_rect(_result_cx, _result_cy);
var _menu_btn = ui_result_menu_rect(_result_cx, _result_cy);
var _ready = ui_button_press_tick(id);
if (_ready == "menu") { application_go_to_main_menu(); exit; }
if (_ready == "again") { application_restart_game(); exit; }
if (ui_press_frames > 0) exit;
button_hover = ui_button_hit(_mx, _my, _play_btn.x, _play_btn.y, _play_btn.w, _play_btn.h);
menu_hover = ui_button_hit(_mx, _my, _menu_btn.x, _menu_btn.y, _menu_btn.w, _menu_btn.h);

if (keyboard_check_pressed(vk_escape)) { ui_button_press_start(id, "menu"); exit; }

if (menu_hover && mouse_check_button_pressed(mb_left)) {
    ui_button_press_start(id, "menu");
    exit;
}

if (keyboard_check_pressed(ord("R")) || keyboard_check_pressed(vk_enter) || (button_hover && mouse_check_button_pressed(mb_left))) {
    ui_button_press_start(id, "again");
    exit;
}

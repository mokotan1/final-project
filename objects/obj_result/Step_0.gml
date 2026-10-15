var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
button_hover = point_in_rectangle(_mx, _my, _gui_w * 0.5 - 150, _gui_h * 0.5 + 100, _gui_w * 0.5 + 150, _gui_h * 0.5 + 154);
menu_hover = point_in_rectangle(_mx, _my, _gui_w * 0.5 - 150, _gui_h * 0.5 + 168, _gui_w * 0.5 + 150, _gui_h * 0.5 + 222);

if (keyboard_check_pressed(vk_escape)) {
    application_go_to_main_menu();
    exit;
}

if (menu_hover && mouse_check_button_pressed(mb_left)) {
    application_go_to_main_menu();
    exit;
}

if (keyboard_check_pressed(ord("R")) || keyboard_check_pressed(vk_enter) || (button_hover && mouse_check_button_pressed(mb_left))) {
    application_restart_game();
    exit;
}

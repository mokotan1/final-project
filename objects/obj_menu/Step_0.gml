if (menu_input_lock > 0) {
    menu_input_lock -= 1;
    exit;
}

var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _cx = _w * 0.5;
var _cy = _h * 0.5;
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

if (keyboard_check_pressed(vk_escape)) {
    if (menu_settings_open) menu_settings_open = false;
    else if (menu_view == 1) menu_view = 0;
}

if (menu_settings_open) {
    var _settings_slider_left = _cx - 240;
    var _settings_slider_right = _cx + 240;
    var _settings_slider_top = 320;
    var _settings_slider_bottom = 368;
    // The thumb remains draggable after the initial click, including outside
    // the bar, which makes the control usable at the native pixel scale.
    if (mouse_check_button(mb_left) && menu_settings_dragging) {
        audio_volume_set(clamp((_mx - _settings_slider_left) / (_settings_slider_right - _settings_slider_left) * 100, 0, 100));
    }
    if (mouse_check_button_pressed(mb_left)) {
        var _slider = [_settings_slider_left - 24, _settings_slider_top - 18, _settings_slider_right + 24, _settings_slider_bottom + 18];
        var _language = [_cx - 270, 398, _cx + 270, 462];
        var _done = [_cx - 120, 478, _cx + 120, 532];
        if (point_in_rectangle(_mx, _my, _slider[0], _slider[1], _slider[2], _slider[3])) {
            menu_settings_dragging = true;
            audio_volume_set(clamp((_mx - _settings_slider_left) / (_settings_slider_right - _settings_slider_left) * 100, 0, 100));
        } else if (point_in_rectangle(_mx, _my, _language[0], _language[1], _language[2], _language[3])) lang_toggle();
        else if (point_in_rectangle(_mx, _my, _done[0], _done[1], _done[2], _done[3])) menu_settings_open = false;
    }
    if (!mouse_check_button(mb_left)) menu_settings_dragging = false;
    exit;
}

menu_hover_play = point_in_rectangle(_mx, _my, _cx - 150, 330, _cx + 150, 390);
menu_hover_settings = point_in_rectangle(_mx, _my, _cx - 150, 412, _cx + 150, 472);
menu_hover_quit = point_in_rectangle(_mx, _my, _cx - 150, 494, _cx + 150, 554);

if (menu_view == 0) {
    if (mouse_check_button_pressed(mb_left)) {
        if (menu_hover_play) menu_view = 1;
        else if (menu_hover_settings) menu_settings_open = true;
        else if (menu_hover_quit) game_end();
    }
    if (keyboard_check_pressed(vk_enter)) menu_view = 1;
    if (keyboard_check_pressed(ord("S"))) menu_settings_open = true;
    exit;
}

var _endless_rect = [750, 165, 1145, 265];
var _classic_rect = [750, 345, 1145, 445];
var _start_rect = [195, 578, 445, 632];
var _back_rect = [845, 578, 1050, 632];
menu_hover_endless = point_in_rectangle(_mx, _my, _endless_rect[0], _endless_rect[1], _endless_rect[2], _endless_rect[3]);
menu_hover_classic = point_in_rectangle(_mx, _my, _classic_rect[0], _classic_rect[1], _classic_rect[2], _classic_rect[3]);
menu_hover_start = point_in_rectangle(_mx, _my, _start_rect[0], _start_rect[1], _start_rect[2], _start_rect[3]);

if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) menu_selected_mode = GAME_MODE_ENDLESS;
if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) menu_selected_mode = GAME_MODE_CLASSIC;
if (mouse_check_button_pressed(mb_left)) {
    if (menu_hover_endless) menu_selected_mode = GAME_MODE_ENDLESS;
    else if (menu_hover_classic) menu_selected_mode = GAME_MODE_CLASSIC;
    else if (menu_hover_start) application_start_game(menu_selected_mode);
    else if (point_in_rectangle(_mx, _my, _back_rect[0], _back_rect[1], _back_rect[2], _back_rect[3])) menu_view = 0;
}
if (keyboard_check_pressed(vk_enter)) application_start_game(menu_selected_mode);

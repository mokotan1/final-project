if (menu_input_lock > 0) {
    menu_input_lock -= 1;
    exit;
}

var _ui_action = ui_button_press_tick(id);
switch (_ui_action) {
    case "done": menu_settings_open = false; break;
    case "story": menu_selected_story = true; menu_talk_tick = 0; break;
    case "endless": menu_selected_story = false; menu_selected_mode = GAME_MODE_ENDLESS; menu_talk_tick = 0; break;
    case "classic": menu_selected_story = false; menu_selected_mode = GAME_MODE_CLASSIC; menu_talk_tick = 0; break;
    case "back": menu_view = 0; break;
    case "start":
        if (menu_selected_story) menu_story_opening = true;
        else application_start_game(menu_selected_mode);
        break;
}
if (ui_press_frames > 0) exit;

if (menu_story_opening) {
    if (keyboard_check_pressed(vk_escape)) menu_story_opening = false;
    else if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)
        || mouse_check_button_pressed(mb_left)) application_start_story();
    exit;
}

var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _cx = _w * 0.5;
var _cy = _h * 0.5;
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

if (menu_view == 1) {
    menu_idle_tick = (menu_idle_tick + 1) mod 161;
    if (menu_talk_tick >= 0) {
        menu_talk_tick += 1;
        if (menu_talk_tick >= 72) menu_talk_tick = -1;
    }
}

if (keyboard_check_pressed(vk_escape)) {
    if (menu_settings_open) menu_settings_open = false;
    else if (menu_view == 1) menu_view = 0;
}

if (menu_settings_open) {
    var _settings_done = ui_settings_primary_rect(_cx);
    menu_hover_settings_done = ui_button_hit(_mx, _my, _settings_done.x, _settings_done.y, _settings_done.w, _settings_done.h);
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
        if (point_in_rectangle(_mx, _my, _slider[0], _slider[1], _slider[2], _slider[3])) {
            menu_settings_dragging = true;
            audio_volume_set(clamp((_mx - _settings_slider_left) / (_settings_slider_right - _settings_slider_left) * 100, 0, 100));
        } else if (point_in_rectangle(_mx, _my, _language[0], _language[1], _language[2], _language[3])) lang_toggle();
        else if (menu_hover_settings_done) ui_button_press_start(id, "done");
    }
    if (!mouse_check_button(mb_left)) menu_settings_dragging = false;
    exit;
}

var _menu_x = 500;
menu_hover_play = point_in_rectangle(_mx, _my, _menu_x - 100, 465, _menu_x + 100, 515);
menu_hover_settings = point_in_rectangle(_mx, _my, _menu_x - 100, 535, _menu_x + 100, 585);
menu_hover_quit = point_in_rectangle(_mx, _my, _menu_x - 100, 605, _menu_x + 100, 655);

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

var _story_rect = [695, 90, 1076, 190];
var _endless_rect = [695, 197, 1076, 297];
var _classic_rect = [695, 304, 1076, 404];
var _start_rect = [780, 590, 1066, 675];
var _back_rect = [20, 590, 306, 675];
menu_hover_endless = point_in_rectangle(_mx, _my, _endless_rect[0], _endless_rect[1], _endless_rect[2], _endless_rect[3]);
menu_hover_classic = point_in_rectangle(_mx, _my, _classic_rect[0], _classic_rect[1], _classic_rect[2], _classic_rect[3]);
menu_hover_story = point_in_rectangle(_mx, _my, _story_rect[0], _story_rect[1], _story_rect[2], _story_rect[3]);
menu_hover_start = point_in_rectangle(_mx, _my, _start_rect[0], _start_rect[1], _start_rect[2], _start_rect[3]);
menu_hover_back = point_in_rectangle(_mx, _my, _back_rect[0], _back_rect[1], _back_rect[2], _back_rect[3]);

if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
    menu_selected_story = false;
    menu_selected_mode = GAME_MODE_ENDLESS;
}
if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
    menu_selected_story = false;
    menu_selected_mode = GAME_MODE_CLASSIC;
}
if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
    if (menu_selected_story) {
        menu_selected_story = false;
        menu_selected_mode = GAME_MODE_CLASSIC;
    } else if (menu_selected_mode == GAME_MODE_ENDLESS) {
        menu_selected_story = true;
    } else {
        menu_selected_mode = GAME_MODE_ENDLESS;
    }
}
if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
    if (menu_selected_story) {
        menu_selected_story = false;
        menu_selected_mode = GAME_MODE_ENDLESS;
    } else if (menu_selected_mode == GAME_MODE_ENDLESS) {
        menu_selected_mode = GAME_MODE_CLASSIC;
    } else {
        menu_selected_story = true;
    }
}
if (keyboard_check_pressed(ord("T"))) menu_selected_story = true;
if (mouse_check_button_pressed(mb_left)) {
    if (menu_hover_endless) ui_button_press_start(id, "endless");
    else if (menu_hover_classic) ui_button_press_start(id, "classic");
    else if (menu_hover_story) ui_button_press_start(id, "story");
    else if (menu_hover_start) ui_button_press_start(id, "start");
    else if (menu_hover_back) ui_button_press_start(id, "back");
}
if (keyboard_check_pressed(vk_enter)) ui_button_press_start(id, "start");

if (variable_global_exists("game_over") && global.game_over && global.game_over_delay <= 0
    && !story_versus_active()) exit;
if (variable_global_exists("game_settings_open") && global.game_settings_open) {
    var _settings_ready = ui_button_press_tick(id);
    if (_settings_ready == "resume") { global.game_settings_open = false; exit; }
    if (_settings_ready == "menu") {
        global.game_settings_open = false;
        application_go_to_main_menu();
        exit;
    }
    if (ui_press_frames > 0) exit;
    var _settings_w = display_get_gui_width();
    var _settings_cx = _settings_w * 0.5;
    var _settings_mx = device_mouse_x_to_gui(0);
    var _settings_my = device_mouse_y_to_gui(0);
    var _settings_primary = ui_settings_primary_rect(_settings_cx);
    var _settings_secondary = ui_settings_secondary_rect(_settings_cx);
    settings_hover_resume = ui_button_hit(_settings_mx, _settings_my, _settings_primary.x, _settings_primary.y, _settings_primary.w, _settings_primary.h);
    settings_hover_main_menu = ui_button_hit(_settings_mx, _settings_my, _settings_secondary.x, _settings_secondary.y, _settings_secondary.w, _settings_secondary.h);
    var _settings_slider_left = _settings_cx - 240;
    var _settings_slider_right = _settings_cx + 240;
    var _settings_slider_top = 320;
    var _settings_slider_bottom = 368;
    if (mouse_check_button(mb_left) && settings_dragging) {
        audio_volume_set(clamp((_settings_mx - _settings_slider_left) / (_settings_slider_right - _settings_slider_left) * 100, 0, 100));
    }
    if (mouse_check_button_pressed(mb_left)) {
        var _settings_slider = [_settings_slider_left - 24, _settings_slider_top - 18, _settings_slider_right + 24, _settings_slider_bottom + 18];
        var _settings_language = [_settings_cx - 270, 398, _settings_cx + 270, 462];
        if (point_in_rectangle(_settings_mx, _settings_my, _settings_slider[0], _settings_slider[1], _settings_slider[2], _settings_slider[3])) {
            settings_dragging = true;
            audio_volume_set(clamp((_settings_mx - _settings_slider_left) / (_settings_slider_right - _settings_slider_left) * 100, 0, 100));
        } else if (point_in_rectangle(_settings_mx, _settings_my, _settings_language[0], _settings_language[1], _settings_language[2], _settings_language[3])) {
            lang_toggle();
        } else if (ui_button_hit(_settings_mx, _settings_my, _settings_primary.x, _settings_primary.y, _settings_primary.w, _settings_primary.h)) {
            ui_button_press_start(id, "resume");
        } else if (ui_button_hit(_settings_mx, _settings_my, _settings_secondary.x, _settings_secondary.y, _settings_secondary.w, _settings_secondary.h)) {
            ui_button_press_start(id, "menu");
        }
    }
    if (!mouse_check_button(mb_left)) settings_dragging = false;
    exit;
}

if (ui_message_timer > 0) ui_message_timer--;
if (keyboard_check_pressed(vk_f9)) {
    global.audio_debug = !variable_global_exists("audio_debug") || !global.audio_debug;
    if (global.audio_debug) audio_sfx("snd_shot", 1);
}

// Keep hit feedback short and bounded even during long cushion chains.
if (variable_global_exists("cushion_fx")) {
    for (var _fx_i = array_length(global.cushion_fx) - 1; _fx_i >= 0; _fx_i--) {
        global.cushion_fx[_fx_i].age += 1;
        if (global.cushion_fx[_fx_i].age >= global.cushion_fx[_fx_i].life) {
            array_delete(global.cushion_fx, _fx_i, 1);
        }
    }
}
if (variable_global_exists("payout_fx")) {
    for (var _pay_i = array_length(global.payout_fx) - 1; _pay_i >= 0; _pay_i--) {
        global.payout_fx[_pay_i].age += 1;
        if (global.payout_fx[_pay_i].age >= global.payout_fx[_pay_i].life) {
            array_delete(global.payout_fx, _pay_i, 1);
        }
    }
}
if (variable_global_exists("score_void_fx") && global.score_void_fx.active) {
    global.score_void_fx.age += 1;
    if (global.score_void_fx.age >= global.score_void_fx.life) {
        global.score_void_fx.active = false;
    }
}
if (variable_global_exists("score_gain_fx") && global.score_gain_fx.active) {
    global.score_gain_fx.age += 1;
    if (global.score_gain_fx.age >= global.score_gain_fx.life) {
        global.score_gain_fx.active = false;
    }
}

// The reel runs until the final second, then a one-second coin payout lands
// exactly as the large score display ends.
var _big_score_visible = variable_global_exists("score_gain_fx") && global.score_gain_fx.active;
if (_big_score_visible && global.score_gain_fx.age <= 1) {
    if (ui_slot_spin_voice != -1) audio_stop_sound(ui_slot_spin_voice);
    if (ui_slot_payout_voice != -1) audio_stop_sound(ui_slot_payout_voice);
    ui_slot_spin_voice = -1;
    ui_slot_payout_voice = -1;
    ui_slot_payout_started = false;
}
if (_big_score_visible) {
    var _remaining = global.score_gain_fx.life - global.score_gain_fx.age;
    if (_remaining > 60 && !ui_slot_payout_started) {
        if (ui_slot_spin_voice == -1 && audio_group_is_loaded(audiogroup_default)) {
            ui_slot_spin_voice = audio_play_sound(snd_slot_spin, 11, true, 0.75);
        }
    } else {
        if (ui_slot_spin_voice != -1) audio_stop_sound(ui_slot_spin_voice);
        ui_slot_spin_voice = -1;
        if (!ui_slot_payout_started && audio_group_is_loaded(audiogroup_default)) {
            ui_slot_payout_voice = audio_play_sound(snd_slot_payout, 12, false, 0.95);
            ui_slot_payout_started = (ui_slot_payout_voice != -1);
        }
    }
} else {
    if (ui_slot_spin_voice != -1) audio_stop_sound(ui_slot_spin_voice);
    if (ui_slot_payout_voice != -1) audio_stop_sound(ui_slot_payout_voice);
    ui_slot_spin_voice = -1;
    ui_slot_payout_voice = -1;
    ui_slot_payout_started = false;
}

if (story_versus_active()) {
    if (global.story_stage_clear_pending && !story_versus_is_fifty_round_match()) exit;
    if (global.story_match_over) exit;
    if (story_versus_is_fifty_round_match() && story_versus_input_locked()) exit;
    if (keyboard_check_pressed(ord("H"))) story_versus_show_help();
    if (story_versus_input_locked()) exit;
    var _shop_ready = ui_button_press_tick(id);
    if (_shop_ready == "shop1") { application_story_purchase_item(1); exit; }
    if (_shop_ready == "shop2") { application_story_purchase_item(2); exit; }
    if (_shop_ready == "shop3") { application_story_purchase_item(3); exit; }
    if (ui_press_frames > 0) exit;
    var _story_item = 0;
    if (keyboard_check_pressed(ord("1"))) _story_item = 1;
    else if (keyboard_check_pressed(ord("2"))) _story_item = 2;
    else if (keyboard_check_pressed(ord("3"))) _story_item = 3;
    if (mouse_check_button_pressed(mb_left)) {
        var _story_mx = device_mouse_x_to_gui(0);
        var _story_my = device_mouse_y_to_gui(0);
        var _shop_slot_y = ui_inventory_y + 22;
        var _shop_gap = ui_slot_gap;
        var _shop_start_x = (display_get_gui_width() - (3 * ui_slot_size + 2 * _shop_gap)) * 0.5;
        if (_story_my >= _shop_slot_y && _story_my <= _shop_slot_y + ui_slot_size) {
            for (var _shop_slot = 0; _shop_slot < 3; _shop_slot++) {
                var _shop_x = _shop_start_x + _shop_slot * (ui_slot_size + _shop_gap);
                if (_story_mx >= _shop_x && _story_mx <= _shop_x + ui_slot_size) {
                    _story_item = _shop_slot + 1;
                    break;
                }
            }
        }
    }
    if (_story_item > 0 && story_versus_is_human_turn()
        && global.story_player_score >= story_versus_item_price(_story_item))
        ui_button_press_start(id, "shop" + string(_story_item));
    exit;
}


if (rules_items_enabled() && variable_global_exists("inventory")) {
    var _inventory_ready = ui_button_press_tick(id);
    if (_inventory_ready == "pageprev") { ui_inventory_page = max(0, ui_inventory_page - 1); exit; }
    if (_inventory_ready == "pagenext") {
        ui_inventory_page = min(max(0, ceil(array_length(global.inventory) / ui_slot_count) - 1), ui_inventory_page + 1);
        exit;
    }
    for (var _ready_choice = 1; _ready_choice <= 3; _ready_choice++) {
        if (_inventory_ready == "reward" + string(_ready_choice)) {
            if (global.reward_choice_open && application_choose_reward(_ready_choice)) {
                ui_message = tr("SELECTED  ", "선택됨  ") + rules_item_name(_ready_choice);
                ui_message_timer = room_speed * 2;
            }
            exit;
        }
    }
    if (string_copy(_inventory_ready, 1, 3) == "inv") {
        var _ready_index = real(string_delete(_inventory_ready, 1, 3));
        if (_ready_index >= 0 && _ready_index < array_length(global.inventory)
            && application_use_inventory_item(_ready_index)) ui_message = tr("ITEM USED", "아이템 사용");
        else ui_message = tr("WAIT UNTIL ALL BALLS STOP", "공이 멈출 때까지 기다리세요");
        ui_message_timer = room_speed * 2;
        exit;
    }
    if (ui_press_frames > 0) exit;
    var _gui_w = display_get_gui_width();
    var _total_w = ui_slot_count * ui_slot_size + (ui_slot_count - 1) * ui_slot_gap;
    var _start_x = (_gui_w - _total_w) * 0.5;
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _pages = max(1, ceil(array_length(global.inventory) / ui_slot_count));
    ui_inventory_page = clamp(ui_inventory_page, 0, _pages - 1);

    if (_my >= ui_inventory_y && _my <= ui_inventory_y + ui_slot_size) {
        if (mouse_wheel_up()) ui_inventory_page = max(0, ui_inventory_page - 1);
        if (mouse_wheel_down()) ui_inventory_page = min(_pages - 1, ui_inventory_page + 1);
    }

    if (global.reward_choice_open) {
        if (mouse_check_button_pressed(mb_left)) {
            var _choice_x = _gui_w * 0.5 - 180;
            for (var _choice = 1; _choice <= 3; _choice++) {
                if (point_in_rectangle(_mx, _my, _choice_x + (_choice - 1) * 120, 280, _choice_x + 100 + (_choice - 1) * 120, 390)) {
                    ui_button_press_start(id, "reward" + string(_choice));
                    exit;
                }
            }
        }
        exit;
    }

    if (!mouse_check_button_pressed(mb_left)) exit;
    if (ui_inventory_page > 0 && point_in_rectangle(_mx, _my, _start_x - 48, ui_inventory_y, _start_x - 8, ui_inventory_y + ui_slot_size)) {
        ui_button_press_start(id, "pageprev");
        exit;
    }
    if (ui_inventory_page < _pages - 1 && point_in_rectangle(_mx, _my, _start_x + _total_w + 8, ui_inventory_y, _start_x + _total_w + 48, ui_inventory_y + ui_slot_size)) {
        ui_button_press_start(id, "pagenext");
        exit;
    }

    for (var _i = 0; _i < ui_slot_count; _i++) {
        var _inventory_index = ui_inventory_page * ui_slot_count + _i;
        if (_inventory_index >= array_length(global.inventory)) break;
        var _slot_x = _start_x + _i * (ui_slot_size + ui_slot_gap);
        if (point_in_rectangle(_mx, _my, _slot_x, ui_inventory_y, _slot_x + ui_slot_size, ui_inventory_y + ui_slot_size)) {
            ui_button_press_start(id, "inv" + string(_inventory_index));
            break;
        }
    }
}

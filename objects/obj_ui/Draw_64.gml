var _gui_w = display_get_gui_width();
// global.ui_pixel_font is retained for English saves; lang_font selects the active atlas.
var _score = variable_global_exists("score") ? global.score : 0;
var _display_score = _score;
if (variable_global_exists("shot_pending_points") && global.shot_pending_points > 0) {
    _display_score += global.shot_pending_points;
}
if (variable_global_exists("score_gain_fx") && global.score_gain_fx.active) {
    var _gain_progress = clamp(global.score_gain_fx.age / 42, 0, 1);
    var _gain_eased = 1 - power(1 - _gain_progress, 4);
    _display_score = global.score_gain_fx.from + round(global.score_gain_fx.gain * _gain_eased);
}
if (variable_global_exists("score_void_fx") && global.score_void_fx.active) {
    var _void_progress = clamp(global.score_void_fx.age / global.score_void_fx.life, 0, 1);
    _display_score += round(global.score_void_fx.from * (1 - _void_progress) * (1 - _void_progress));
}
var _chances = variable_global_exists("chances") ? global.chances : 3;
var _goal = variable_global_exists("item_goal") ? global.item_goal : 3;
var _meter = variable_global_exists("item_meter") ? global.item_meter : 0;
var _best = variable_global_exists("best_score") ? global.best_score : 0;
var _foul_obj = asset_get_index("obj_ball_foul");
var _fouls = (_foul_obj != -1) ? instance_number(_foul_obj) : 0;
var _pending = variable_global_exists("pending_foul_spawns") ? global.pending_foul_spawns : 0;
var _reserved_fouls = _fouls + _pending;
var _next_item = (variable_global_exists("milestone_index") && global.milestone_index < 3) ? tr_item(rules_milestone_item(global.milestone_index)) : tr("CHOICE", "선택");
var _foul_cap = rules_foul_cap();
var _items_on = rules_items_enabled();
var _next_desc = (!_items_on) ? tr("SCORE ONLY", "점수만")
    : ((_reserved_fouls >= _foul_cap) ? tr("ITEM ONLY", "아이템만") : tr("FOUL + ", "파울 + ") + _next_item);
var _best_gap = max(0, _best - _display_score);
var _power = 0;
if (instance_exists(obj_cue) && variable_instance_exists(obj_cue, "power_normalized")) {
    _power = clamp(obj_cue.power_normalized, 0, 1);
}

lang_font_init();
draw_set_alpha(1);

// Cushion hits build a short visual chain; the target hit cashes it out.
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
if (variable_global_exists("cushion_fx")) {
    for (var _fx_i = 0; _fx_i < array_length(global.cushion_fx); _fx_i++) {
        var _fx = global.cushion_fx[_fx_i];
        var _progress = _fx.age / _fx.life;
        var _fade = 1 - _progress;
        var _hit_color = (_fx.count == 1) ? make_color_rgb(78, 225, 240)
            : ((_fx.count == 2) ? make_color_rgb(255, 214, 74) : make_color_rgb(255, 115, 204));
        var _ring = 10 + 38 * _progress;

        draw_set_color(_hit_color);
        draw_set_alpha(0.65 * _fade);
        draw_circle(_fx.x, _fx.y, _ring, true);
        draw_set_alpha(0.28 * _fade);
        draw_circle(_fx.x, _fx.y, _ring + 7, true);
        draw_set_alpha(0.8 * _fade);
        for (var _ray = 0; _ray < 8; _ray++) {
            var _direction = _ray * 45 + _fx.count * 17;
            var _inner = 13 + 27 * _progress;
            var _outer = _inner + 8 + 5 * _fade;
            draw_line_width(_fx.x + lengthdir_x(_inner, _direction), _fx.y + lengthdir_y(_inner, _direction),
                _fx.x + lengthdir_x(_outer, _direction), _fx.y + lengthdir_y(_outer, _direction), 2);
        }

        // Callouts stay solid for 0.5s, then fade over the remaining 0.9s.
        // Stagger repeated cushion hits so their larger pixel labels remain
        // legible when several rails are touched in one shot.
        var _text_hold = 30;
        var _text_fade = max(1, _fx.life - _text_hold);
        var _text_progress = clamp((_fx.age - _text_hold) / _text_fade, 0, 1);
        var _label_lane = (_fx_i mod 3) - 1;
        var _label_y = max(108, round(_fx.y - 52 - 20 * _label_lane - 16 * _text_progress));
        var _bonus_label = "x" + string(power(_fx.risk ? 10 : 2, _fx.count));
        var _label = "CUSHION " + string(_fx.count) + "   " + _bonus_label;
        var _label_scale = 3;
        var _half_label_width = pixel_text_width(_label) * _label_scale * 0.5;
        var _label_x = clamp(round(_fx.x + ((_fx_i mod 2) == 0 ? -10 : 10)), _half_label_width + 8, _gui_w - _half_label_width - 8);
        draw_set_color(c_black);
        draw_set_alpha(0.7 * (1 - _text_progress));
        pixel_draw_text_transformed(_label_x + 3, _label_y + 3, _label, _label_scale, _label_scale, 0);
        draw_set_color(_hit_color);
        draw_set_alpha(1 - _text_progress);
        pixel_draw_text_transformed(_label_x, _label_y, _label, _label_scale, _label_scale, 0);
    }
}
if (variable_global_exists("payout_fx")) {
    for (var _pay_i = 0; _pay_i < array_length(global.payout_fx); _pay_i++) {
        var _pay = global.payout_fx[_pay_i];
        var _pay_progress = _pay.age / _pay.life;
        // Match cushion callouts: let the earned points read clearly before the
        // payout drifts upward and fades. Keep large Risk Shot values in frame.
        var _pay_hold = 30;
        var _pay_fade_progress = clamp((_pay.age - _pay_hold) / max(1, _pay.life - _pay_hold), 0, 1);
        var _pay_fade = 1 - _pay_fade_progress;
        var _pay_label = "+" + string(_pay.points);
        var _pay_sub_label = "x" + string(_pay.multiplier) + " PAYOUT";
        // Keep pixel glyphs crisp at the same integer scale as cushion labels;
        // only step down when a long value cannot fit the GUI width.
        var _pay_scale = 3;
        if (pixel_text_width(_pay_label) * _pay_scale > _gui_w - 32) _pay_scale = 2;
        if (pixel_text_width(_pay_label) * _pay_scale > _gui_w - 32) _pay_scale = 1;
        var _pay_sub_scale = 2;
        if (pixel_text_width(_pay_sub_label) * _pay_sub_scale > _gui_w - 32) _pay_sub_scale = 1;
        var _pay_half_width = pixel_text_width(_pay_label) * _pay_scale * 0.5;
        var _pay_sub_half_width = pixel_text_width(_pay_sub_label) * _pay_sub_scale * 0.5;
        var _pay_half_max = max(_pay_half_width, _pay_sub_half_width);
        var _pay_x = clamp(_pay.x, _pay_half_max + 8, _gui_w - _pay_half_max - 8);
        var _pay_y = max(150, _pay.y - 42 - 42 * _pay_progress);
        draw_set_alpha(0.85 * _pay_fade);
        draw_set_color(c_black);
        pixel_draw_text_transformed(_pay_x + 4, _pay_y + 4, _pay_label, _pay_scale, _pay_scale, 0);
        draw_set_color(make_color_rgb(255, 229, 110));
        draw_set_alpha(_pay_fade);
        pixel_draw_text_transformed(_pay_x, _pay_y, _pay_label, _pay_scale, _pay_scale, 0);
        draw_set_color(c_white);
        pixel_draw_text_transformed(_pay_x, _pay_y + 30 * _pay_sub_scale, _pay_sub_label, _pay_sub_scale, _pay_sub_scale, 0);
    }
}
if (variable_global_exists("score_gain_fx") && global.score_gain_fx.active) {
    var _big = global.score_gain_fx;
    var _big_t = clamp(_big.age / 42, 0, 1);
    var _big_eased = 1 - power(1 - _big_t, 4);
    var _big_alpha = min(1, _big.age / 5) * min(1, (_big.life - _big.age) / 28);
    var _big_y = display_get_gui_height() * 0.48 - 18 * min(1, _big.age / 24);
    var _burst = max(0, 1 - _big.age / 24);
    var _number_scale = 2.85 + 1.05 * _burst;
    draw_set_alpha(0.18 * _burst);
    draw_set_color(make_color_rgb(255, 210, 74));
    draw_rectangle(0, 0, _gui_w, display_get_gui_height(), false);
    draw_set_alpha(0.86 * _big_alpha);
    draw_set_color(make_color_rgb(9, 23, 27));
    draw_roundrect(_gui_w * 0.5 - 260, _big_y - 92, _gui_w * 0.5 + 260, _big_y + 96, false);
    draw_set_alpha(_big_alpha);
    draw_set_color(make_color_rgb(255, 207, 78));
    draw_roundrect(_gui_w * 0.5 - 260, _big_y - 92, _gui_w * 0.5 + 260, _big_y + 96, true);
    var _big_title = (_big.life - _big.age <= 60) ? "PAYOUT!" : "BIG SCORE";
    pixel_draw_text_transformed(_gui_w * 0.5, _big_y - 62, _big_title, 1.4, 1.4, 0);
    pixel_draw_text_transformed(_gui_w * 0.5, _big_y - 6,
        "+" + string(round(_big.gain * _big_eased)), _number_scale, _number_scale, 0);
    draw_set_color(c_white);
    pixel_draw_text_transformed(_gui_w * 0.5, _big_y + 62,
        "TOTAL " + string(_big.from + round(_big.gain * _big_eased)), 1.25, 1.25, 0);
}
if (variable_global_exists("score_void_fx") && global.score_void_fx.active) {
    var _void = global.score_void_fx;
    var _void_t = clamp(_void.age / _void.life, 0, 1);
    var _void_points = round(_void.from * (1 - _void_t) * (1 - _void_t));
    var _void_alpha = min(1, (1 - _void_t) * 3);
    draw_set_alpha(0.12 * _void_alpha);
    draw_set_color(make_color_rgb(230, 35, 55));
    draw_rectangle(0, 0, _gui_w, display_get_gui_height(), false);
    draw_set_alpha(_void_alpha);
    draw_set_color(c_black);
    pixel_draw_text_transformed(_void.x + 3, _void.y - 50 + 3, "FOUL!", 2.1, 2.1, 0);
    pixel_draw_text_transformed(_void.x + 3, _void.y - 15 + 3, string(_void_points) + " -> 0", 1.7, 1.7, 0);
    draw_set_color(make_color_rgb(255, 78, 88));
    pixel_draw_text_transformed(_void.x, _void.y - 50, "FOUL!", 2.1, 2.1, 0);
    pixel_draw_text_transformed(_void.x, _void.y - 15, string(_void_points) + " -> 0", 1.7, 1.7, 0);
}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

if (story_versus_active()) {
    story_versus_draw_hud();
    exit;
}

// Keep all gameplay HUD content above the table rail (y ~= 76) in the native
// 1280 x 720 GUI space, with bounded columns so labels stay inside the panel.
var _power_left = 24;
var _power_right = clamp(_gui_w * 0.27, 250, 330);
var _panel_left = _power_right + 16;
var _panel_right = _gui_w - 18;
var _panel_mid = _panel_left + (_panel_right - _panel_left) * 0.5;
    var _status = "";
var _status_color = make_color_rgb(255, 190, 120);
if (_pending > 0) {
    _status = "FOUL PENDING " + string(_pending);
} else if (variable_global_exists("shot_pending_points") && global.shot_pending_points > 0) {
    _status = "PENDING +" + string(global.shot_pending_points);
    _status_color = make_color_rgb(255, 229, 110);
} else if (variable_global_exists("shot_loss_reason") && global.shot_loss_timer > 0 && global.shot_loss_reason != "") {
    _status = global.shot_loss_reason;
} else if (variable_global_exists("new_best_timer") && global.new_best_timer > 0) {
    _status = "NEW BEST";
    _status_color = make_color_rgb(255, 235, 120);
}

draw_set_color(make_color_rgb(10, 23, 27));
draw_roundrect(_power_left, 8, _power_right, 76, false);
draw_set_color(make_color_rgb(213, 168, 85));
ui_text_fit_px(_power_left + 14, 12, tr("POWER", "파워"), _power_right - _power_left - 28, 2, make_color_rgb(213, 168, 85));
draw_set_color(make_color_rgb(42, 60, 63));
draw_roundrect(_power_left + 14, 50, _power_right - 14, 66, false);
draw_set_color(make_color_rgb(237, 187, 76));
draw_roundrect(_power_left + 14, 50, _power_left + 14 + (_power_right - _power_left - 28) * _power, 66, false);

draw_set_color(make_color_rgb(10, 23, 27));
draw_roundrect(_panel_left, 8, _panel_right, 76, false);
draw_set_color(c_white);
draw_set_halign(fa_left);
ui_text_fit_px(_panel_left + 14, 11, tr("CHANCES ", "기회 ") + string(_chances) + "/3", 230, 2, c_white);
draw_set_halign(fa_right);
ui_text_fit_px(_panel_mid - 8, 11, tr("SCORE ", "점수 ") + pixel_score_text(_display_score), 260, 2, c_white);
draw_set_halign(fa_right);
ui_text_fit_px(_panel_right - 14, 11, tr("BEST ", "최고 ") + pixel_score_text(_best), 360, 2, c_white);
draw_set_halign(fa_left);
if (_status != "") {
    ui_text_fit_px(_panel_left + 14, 43, _status, 260, 2, _status_color);
} else {
    ui_text_fit_px(_panel_left + 14, 43, (_best <= 0) ? tr("FIRST RECORD", "첫 기록") : tr("GAP ", "간격 ") + pixel_score_text(_best_gap), 260, 2, make_color_rgb(213, 168, 85));
}
draw_set_halign(fa_right);
ui_text_fit_px(_panel_mid - 8, 43, tr("FOUL ", "파울 ") + string(_fouls) + "/" + string(_foul_cap), 230, 2, make_color_rgb(213, 168, 85));
draw_set_halign(fa_right);
if (_items_on) {
    ui_text_fit_px(_panel_right - 14, 43, tr("ITEM ", "아이템 ") + string(_meter) + "/" + string(_goal) + " " + _next_desc, 400, 2, c_white);
} else {
    draw_set_color(make_color_rgb(213, 168, 85));
    ui_text_fit_px(_panel_right - 14, 43, tr_mode() + "  " + _next_desc, 400, 2, make_color_rgb(213, 168, 85));
}

// Placement is the first required action, and the Move item uses the same mode.
if (variable_global_exists("place_mode") && global.place_mode && !global.balls_moving) {
    var _hint_x = _gui_w * 0.5;
    draw_set_alpha(0.86);
    draw_set_color(make_color_rgb(10, 23, 27));
    draw_roundrect(_hint_x - 320, 145, _hint_x + 320, 237, false);
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_color(make_color_rgb(255, 222, 116));
    var _place_title = (variable_global_exists("place_from_item") && global.place_from_item)
        ? tr("CLICK THE TABLE TO MOVE YOUR BALL", "테이블을 클릭해 공을 옮기세요")
        : tr("CLICK THE TABLE TO PLACE YOUR BALL", "테이블을 클릭해 공을 놓으세요");
    pixel_draw_text_transformed(_hint_x, 162, _place_title, 2, 2, 0, true);
    draw_set_color(c_white);
    pixel_draw_text_transformed(_hint_x, 197, tr("PICK AN OPEN SPOT ON THE TABLE", "초록 영역의 빈 곳을 선택하세요"), 2, 2, 0);
}

if (_items_on) {
var _total_w = ui_slot_count * ui_slot_size + (ui_slot_count - 1) * ui_slot_gap;
var _start_x = (_gui_w - _total_w) * 0.5;
var _inventory_length = variable_global_exists("inventory") ? array_length(global.inventory) : 0;
var _pages = max(1, ceil(_inventory_length / ui_slot_count));
ui_inventory_page = clamp(ui_inventory_page, 0, _pages - 1);
draw_set_halign(fa_center);
draw_set_color(make_color_rgb(213, 168, 85));
pixel_draw_text(_gui_w * 0.5, ui_inventory_y - 34, tr("INVENTORY", "인벤토리"));

for (var _i = 0; _i < ui_slot_count; _i++) {
    var _x = _start_x + _i * (ui_slot_size + ui_slot_gap);
    var _inventory_index = ui_inventory_page * ui_slot_count + _i;
    var _slot_hover = ui_button_hit(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0),
        _x, ui_inventory_y, ui_slot_size, ui_slot_size);
    var _slot_state = (_inventory_index >= _inventory_length) ? UI_BUTTON_DISABLED
        : ui_button_state(_slot_hover, ui_button_is_pressed(id, "inv" + string(_inventory_index)));
    ui_button_draw("", _x, ui_inventory_y, ui_slot_size, ui_slot_size, true, _slot_state);
    if (_inventory_index < _inventory_length) {
        var _item = global.inventory[_inventory_index];
        var _icon = -1;
        if (_item == rules_item_move()) _icon = spr_item_move;
        else if (_item == rules_item_risk_shot()) _icon = spr_item_risk_shot;
        else if (_item == rules_item_remove_foul()) _icon = spr_item_remove;
        if (_icon != -1) draw_sprite_ext(_icon, 0, _x + ui_slot_size * 0.5,
            ui_inventory_y + ui_slot_size * 0.5, 0.7, 0.7, 0, c_white, 1);
    }
}

ui_button_draw("<", _start_x - 48, ui_inventory_y, 40, ui_slot_size, true,
    ui_inventory_page <= 0 ? UI_BUTTON_DISABLED
        : ui_button_state(ui_button_hit(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0),
            _start_x - 48, ui_inventory_y, 40, ui_slot_size), ui_button_is_pressed(id, "pageprev")));
ui_button_draw(">", _start_x + _total_w + 8, ui_inventory_y, 40, ui_slot_size, true,
    ui_inventory_page >= _pages - 1 ? UI_BUTTON_DISABLED
        : ui_button_state(ui_button_hit(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0),
            _start_x + _total_w + 8, ui_inventory_y, 40, ui_slot_size), ui_button_is_pressed(id, "pagenext")));
draw_set_color(make_color_rgb(213, 168, 85));
pixel_draw_text(_gui_w * 0.5, ui_inventory_y + ui_slot_size + 10, string(ui_inventory_page + 1) + " / " + string(_pages));
}

if (ui_message_timer > 0 && _items_on) {
    draw_set_color(c_white);
    pixel_draw_text(_gui_w * 0.5, ui_inventory_y - 50, ui_message);
}

if (_items_on && variable_global_exists("reward_choice_open") && global.reward_choice_open) {
    draw_set_halign(fa_center);
    draw_set_color(make_color_rgb(10, 23, 27));
    draw_roundrect(_gui_w * 0.5 - 210, 230, _gui_w * 0.5 + 210, 430, false);
    draw_set_color(c_white);
    pixel_draw_text(_gui_w * 0.5, 250, tr("CHOOSE YOUR REWARD", "보상을 선택하세요"));
    pixel_draw_text(_gui_w * 0.5, 268, tr("OWNED  ", "소유  ") + string(array_length(global.inventory)));
    for (var _choice = 1; _choice <= 3; _choice++) {
        var _cx = _gui_w * 0.5 - 180 + (_choice - 1) * 120;
        ui_button_draw("", _cx, 280, 100, 110, true,
            ui_button_state(ui_button_hit(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0),
                _cx, 280, 100, 110), ui_button_is_pressed(id, "reward" + string(_choice))));
        var _icon = (_choice == 1) ? spr_item_move : ((_choice == 2) ? spr_item_risk_shot : spr_item_remove);
        draw_sprite(_icon, 0, _cx + 50, 325);
        draw_set_color(c_white);
        ui_text_fit_px(_cx + 50, 365, (_choice == 1) ? "PLACE BALL" : ((_choice == 2) ? "10X RISK" : "REMOVE FOUL"), 92, 1, c_white);
    }
}

// Hover copy is drawn last so it remains readable over the table and reward
// cards. It deliberately ignores empty inventory slots and never appears over
// the paused settings screen.
if (_items_on && !(variable_global_exists("game_settings_open") && global.game_settings_open)) {
    var _tooltip_item = -1;
    var _tooltip_mx = device_mouse_x_to_gui(0);
    var _tooltip_my = device_mouse_y_to_gui(0);
    if (variable_global_exists("reward_choice_open") && global.reward_choice_open) {
        var _tooltip_choice_x = _gui_w * 0.5 - 180;
        for (var _tooltip_choice = 1; _tooltip_choice <= 3; _tooltip_choice++) {
            var _tooltip_card_x = _tooltip_choice_x + (_tooltip_choice - 1) * 120;
            if (point_in_rectangle(_tooltip_mx, _tooltip_my, _tooltip_card_x, 280, _tooltip_card_x + 100, 390)) {
                _tooltip_item = _tooltip_choice;
                break;
            }
        }
    } else {
        var _tooltip_total_w = ui_slot_count * ui_slot_size + (ui_slot_count - 1) * ui_slot_gap;
        var _tooltip_start_x = (_gui_w - _tooltip_total_w) * 0.5;
        var _tooltip_inventory_length = variable_global_exists("inventory") ? array_length(global.inventory) : 0;
        var _tooltip_page = variable_instance_exists(id, "ui_inventory_page") ? ui_inventory_page : 0;
        for (var _tooltip_slot = 0; _tooltip_slot < ui_slot_count; _tooltip_slot++) {
            var _tooltip_index = _tooltip_page * ui_slot_count + _tooltip_slot;
            var _tooltip_slot_x = _tooltip_start_x + _tooltip_slot * (ui_slot_size + ui_slot_gap);
            if (_tooltip_index < _tooltip_inventory_length
                && point_in_rectangle(_tooltip_mx, _tooltip_my, _tooltip_slot_x, ui_inventory_y, _tooltip_slot_x + ui_slot_size, ui_inventory_y + ui_slot_size)) {
                var _candidate_item = global.inventory[_tooltip_index];
                if (_candidate_item == rules_item_move() || _candidate_item == rules_item_risk_shot() || _candidate_item == rules_item_remove_foul()) {
                    _tooltip_item = _candidate_item;
                }
                break;
            }
        }
    }
    if (_tooltip_item > 0) {
        var _tooltip_w = 560;
        var _tooltip_h = 148;
        var _tooltip_x = _tooltip_mx + 20;
        var _tooltip_y = _tooltip_my + 20;
        if (_tooltip_x + _tooltip_w > _gui_w - 8) _tooltip_x = _tooltip_mx - _tooltip_w - 20;
        if (_tooltip_y + _tooltip_h > display_get_gui_height() - 8) _tooltip_y = _tooltip_my - _tooltip_h - 16;
        _tooltip_x = clamp(_tooltip_x, 8, _gui_w - _tooltip_w - 8);
        _tooltip_y = clamp(_tooltip_y, 8, display_get_gui_height() - _tooltip_h - 8);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_alpha(0.88);
        draw_set_color(c_black);
        draw_rectangle(_tooltip_x + 4, _tooltip_y + 4, _tooltip_x + _tooltip_w + 4, _tooltip_y + _tooltip_h + 4, false);
        draw_set_alpha(1);
        draw_set_color(make_color_rgb(10, 23, 27));
        draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + _tooltip_w, _tooltip_y + _tooltip_h, false);
        draw_set_color(make_color_rgb(213, 168, 85));
        draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + _tooltip_w, _tooltip_y + _tooltip_h, true);
        ui_text_fit_px(_tooltip_x + 16, _tooltip_y + 16, tr_item(_tooltip_item), _tooltip_w - 32, 2, make_color_rgb(255, 222, 116));
        ui_text_fit_px(_tooltip_x + 16, _tooltip_y + 57, tr_item_effect(_tooltip_item), _tooltip_w - 32, 2, c_white);
        ui_text_fit_px(_tooltip_x + 16, _tooltip_y + 100, tr("USE: ", "사용: ") + tr_item_hint(_tooltip_item), _tooltip_w - 32, 2, make_color_rgb(179, 224, 210));
        draw_set_alpha(1);
    }
}

if (variable_global_exists("game_settings_open") && global.game_settings_open) {
    draw_sprite(global.audio_enabled ? spr_menu_settings_on : spr_menu_settings_off, 0, 0, 0);
    var _settings_cx = _gui_w * 0.5;
    ui_settings_panel_draw(_settings_cx, "RESUME", ui_button_state(settings_hover_resume, ui_button_is_pressed(id, "resume")),
        "MAIN MENU", ui_button_state(settings_hover_main_menu, ui_button_is_pressed(id, "menu")));
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
if (variable_global_exists("audio_debug") && global.audio_debug) {
    draw_set_color(make_color_rgb(10, 23, 27));
    draw_roundrect(12, 622, 350, 702, false);
    draw_set_color(c_white);
    pixel_draw_text(22, 635, "F9 SOUND TEST");
    pixel_draw_text(22, 660, variable_global_exists("audio_last_status") ? global.audio_last_status : "NO SOUND TRIGGERED");
    pixel_draw_text(22, 682, "GROUP " + string(audio_group_is_loaded(audiogroup_default)));
}

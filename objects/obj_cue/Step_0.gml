if (variable_global_exists("game_settings_open") && global.game_settings_open) {
    dragging = false;
    drag_power = 0;
    power_normalized = 0;
    exit;
}

if (!instance_exists(player)) player = instance_find(obj_ball_player, 0);
if (shot_input_lock > 0) shot_input_lock -= 1;

var _place_mode = variable_global_exists("place_mode") && global.place_mode;
var _shot_active = variable_global_exists("shot_active") && global.shot_active;
var _game_over = variable_global_exists("game_over") && global.game_over;
var _reward_blocked = variable_global_exists("pending_reward_choice") && (global.pending_reward_choice || global.reward_choice_open);
var _can_shoot = instance_exists(player) && shot_input_lock <= 0 && !_place_mode && !_shot_active && !_game_over && !_reward_blocked && physics_all_balls_stopped();

if (!_can_shoot) {
    dragging = false;
    drag_power = 0;
    power_normalized = 0;
    exit;
}

aim_direction = point_direction(mouse_x, mouse_y, player.x, player.y);

if (mouse_check_button_pressed(mb_left) && point_distance(mouse_x, mouse_y, player.x, player.y) <= 56) {
    dragging = true;
}

if (dragging && mouse_check_button(mb_left)) {
    drag_power = clamp(point_distance(mouse_x, mouse_y, player.x, player.y) * power_per_pixel, 0, max_power);
    power_normalized = drag_power / max_power;
    aim_direction = point_direction(mouse_x, mouse_y, player.x, player.y);
}

if (dragging && mouse_check_button_released(mb_left)) {
    var _shot_power = drag_power;
    var _shot_direction = aim_direction;
    dragging = false;
    drag_power = 0;
    power_normalized = 0;
    physics_shoot(player, _shot_direction, _shot_power);
}

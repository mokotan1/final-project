if (!instance_exists(player) || !physics_all_balls_stopped()) exit;
var _place_mode = variable_global_exists("place_mode") && global.place_mode;
if (_place_mode) exit;

var _angle = point_direction(player.x, player.y, mouse_x, mouse_y);
var _pullback = dragging ? drag_power * 3 : 0;
var _near_x = player.x + lengthdir_x(28 + _pullback, _angle);
var _near_y = player.y + lengthdir_y(28 + _pullback, _angle);
var _far_x = player.x + lengthdir_x(170 + _pullback, _angle);
var _far_y = player.y + lengthdir_y(170 + _pullback, _angle);

// Show a short, approximate first-cushion prediction while charging.
// The line ends at the distance the ball can travel before friction stops it.
if (dragging && drag_power > 0) {
    var _bounds = physics_table_bounds();
    var _radius = variable_instance_exists(player, "physics_radius") ? player.physics_radius : 16;
    var _left = _bounds.left + _radius;
    var _top = _bounds.top + _radius;
    var _right = _bounds.right - _radius;
    var _bottom = _bounds.bottom - _radius;
    var _dir_x = lengthdir_x(1, aim_direction);
    var _dir_y = lengthdir_y(1, aim_direction);
    var _distance_to_cushion = 1000000;

    if (_dir_x > 0) _distance_to_cushion = min(_distance_to_cushion, (_right - player.x) / _dir_x);
    else if (_dir_x < 0) _distance_to_cushion = min(_distance_to_cushion, (_left - player.x) / _dir_x);
    if (_dir_y > 0) _distance_to_cushion = min(_distance_to_cushion, (_bottom - player.y) / _dir_y);
    else if (_dir_y < 0) _distance_to_cushion = min(_distance_to_cushion, (_top - player.y) / _dir_y);

    var _friction = variable_instance_exists(player, "physics_friction") ? player.physics_friction : 0.045;
    var _stop_speed = variable_instance_exists(player, "physics_stop_speed") ? player.physics_stop_speed : 0.08;
    var _steps = max(0, ceil((drag_power - _stop_speed) / max(_friction, 0.0001)));
    var _stopping_distance = max(0, _steps * drag_power - _friction * _steps * (_steps + 1) * 0.5);
    var _guide_distance = min(_distance_to_cushion, _stopping_distance);
    var _guide_x = player.x + _dir_x * _guide_distance;
    var _guide_y = player.y + _dir_y * _guide_distance;
    var _hits_cushion = _distance_to_cushion <= _stopping_distance;

    draw_set_alpha(0.42);
    draw_set_color(c_aqua);
    draw_line_width(player.x, player.y, _guide_x, _guide_y, 3);
    draw_set_alpha(0.9);
    if (_hits_cushion) {
        draw_circle(_guide_x, _guide_y, 7, false);
        draw_line_width(_guide_x - 5, _guide_y, _guide_x + 5, _guide_y, 2);
        draw_line_width(_guide_x, _guide_y - 5, _guide_x, _guide_y + 5, 2);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}
draw_sprite_ext(spr_cue, 0, _near_x, _near_y, 1, 1, _angle, c_white, 1);

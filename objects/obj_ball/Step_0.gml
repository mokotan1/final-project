if (variable_global_exists("game_settings_open") && global.game_settings_open) exit;
physics_ball_step();
var _circumference = 2 * pi * physics_radius;
if (_circumference > 0) {
    scroll_x += scroll_strength * hspeed / _circumference;
    scroll_y += scroll_strength * vspeed / _circumference;
    scroll_x -= floor(scroll_x);
    scroll_y -= floor(scroll_y);
}

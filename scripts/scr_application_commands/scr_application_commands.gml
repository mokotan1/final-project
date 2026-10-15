/// Commands are the mutation boundary used by UI and lifecycle objects.

function application_use_inventory_item(_index) {
    if (!rules_items_enabled()) return false;
    if (global.game_over || global.balls_moving || global.shot_active || global.pending_reward_choice) return false;
    if (_index < 0 || _index >= array_length(global.inventory)) return false;

    var _item = global.inventory[_index];
    var _applied = false;

    switch (_item) {
        case 1:
            global.place_mode = true;
            global.place_from_item = true;
            _applied = true;
            break;

        case 2:
            if (!global.risk_shot_armed) {
                global.risk_shot_armed = true;
                _applied = true;
            }
            break;

        case 3:
            var _foul_object = asset_get_index("obj_ball_foul");
            if (_foul_object != -1) {
                var _remove_count = min(1, instance_number(_foul_object));
                var _removed = 0;
                for (var _foul_i = _remove_count - 1; _foul_i >= 0; _foul_i--) {
                    var _foul = instance_find(_foul_object, _foul_i);
                    if (_foul != noone) {
                        with (_foul) instance_destroy();
                        _removed += 1;
                        _applied = true;
                    }
                }
                if (_applied) global.foul_count = max(0, global.foul_count - _removed);
            }
            break;
    }

    if (_applied) {
        array_delete(global.inventory, _index, 1);
        audio_sfx("snd_item", 0.6);
    }
    return _applied;
}

function application_place_player_ball(_player_ball, _x, _y) {
    if (!global.place_mode || global.balls_moving || !instance_exists(_player_ball)) return false;

    var _bounds = physics_table_bounds();
    var _radius = variable_instance_exists(_player_ball, "physics_radius") ? _player_ball.physics_radius : 16;
    if (_x - _radius < _bounds.left || _x + _radius > _bounds.right) return false;
    if (_y - _radius < _bounds.top || _y + _radius > _bounds.bottom) return false;
    if (!application_ball_position_clear(_x, _y, _radius, _player_ball)) return false;

    _player_ball.x = _x;
    _player_ball.y = _y;
    _player_ball.speed = 0;
    _player_ball.hspeed = 0;
    _player_ball.vspeed = 0;
    global.place_mode = false;
    global.place_from_item = false;
    return true;
}

function application_take_pending_foul_spawn() {
    if (global.pending_foul_spawns <= 0) return false;
    global.pending_foul_spawns -= 1;
    return true;
}

function application_choose_reward(_item) {
    if (!rules_items_enabled()) return false;
    if (!global.reward_choice_open || global.balls_moving || global.shot_active) return false;
    if (_item < 1 || _item > 3) return false;
    array_push(global.inventory, _item);
    global.reward_choice_open = false;
    array_delete(global.pending_reward_queue, 0, 1);
    var _foul_reward = global.pending_reward_foul_queue[0];
    array_delete(global.pending_reward_foul_queue, 0, 1);
    if (_foul_reward && global.foul_count + global.pending_foul_spawns < rules_foul_cap()) {
        global.pending_foul_spawns += 1;
    }
    global.pending_reward_choice = array_length(global.pending_reward_queue) > 0;
    audio_sfx("snd_item", 0.55);
    return true;
}

function application_restart_game() {
    game_mode_ensure();
    var _game_room = asset_get_index("rm_game");
    if (_game_room != -1) room_goto(_game_room);
    return _game_room != -1;
}

function application_start_game(_mode) {
    game_mode_ensure();
    global.game_mode = (_mode == GAME_MODE_CLASSIC) ? GAME_MODE_CLASSIC : GAME_MODE_ENDLESS;
    return application_restart_game();
}

function application_go_to_main_menu() {
    var _menu_room = asset_get_index("rm_menu");
    if (_menu_room != -1) room_goto(_menu_room);
}

function application_spawn_ball(_asset_name) {
    var _object = asset_get_index(_asset_name);
    if (_object == -1) return noone;

    var _ball_parent = asset_get_index("obj_ball");
    var _bounds = physics_table_bounds();
    var _radius = 16;
    if (_asset_name == "obj_ball_foul") {
        var _foul_object = asset_get_index("obj_ball_foul");
        if (_foul_object != -1 && instance_number(_foul_object) + global.pending_foul_spawns > rules_foul_cap()) return noone;
    }
    repeat (40) {
        var _x = random_range(_bounds.left + _radius, _bounds.right - _radius);
        var _y = random_range(_bounds.top + _radius, _bounds.bottom - _radius);
        if (_asset_name == "obj_ball_foul") {
            var _player = instance_find(asset_get_index("obj_ball_player"), 0);
            var _target = instance_find(asset_get_index("obj_ball_target"), 0);
            if (instance_exists(_player) && instance_exists(_target)) {
                var _vx = _target.x - _player.x;
                var _vy = _target.y - _player.y;
                var _len2 = max(1, _vx * _vx + _vy * _vy);
                var _t = clamp(((_x - _player.x) * _vx + (_y - _player.y) * _vy) / _len2, 0, 1);
                var _lx = _player.x + _t * _vx;
                var _ly = _player.y + _t * _vy;
                if (point_distance(_x, _y, _lx, _ly) < 48) continue;
            }
        }
        if (_ball_parent == -1 || application_ball_position_clear(_x, _y, _radius, noone)) {
            return instance_create_layer(_x, _y, "Instances", _object);
        }
    }

    return noone;
}

function application_ball_position_clear(_x, _y, _radius, _ignore) {
    var _ball_parent = asset_get_index("obj_ball");
    if (_ball_parent == -1) return true;

    var _count = instance_number(_ball_parent);
    for (var _i = 0; _i < _count; _i++) {
        var _other = instance_find(_ball_parent, _i);
        if (_other != noone && _other != _ignore) {
            var _other_radius = variable_instance_exists(_other, "physics_radius") ? _other.physics_radius : 16;
            if (point_distance(_x, _y, _other.x, _other.y) < _radius + _other_radius + 4) return false;
        }
    }
    return true;
}

function application_destroy_all_balls() {
    var _ball_parent = asset_get_index("obj_ball");
    if (_ball_parent != -1) {
        with (_ball_parent) instance_destroy();
    }
}

function application_spawn_initial_balls() {
    application_spawn_ball("obj_ball_player");
    application_spawn_ball("obj_ball_target");
    repeat (global.foul_count) application_spawn_ball("obj_ball_foul");
}

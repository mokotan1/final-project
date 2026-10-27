/// @description Deterministic billiards helpers used by obj_ball and obj_cue.

function physics_table_bounds() {
    var _left = variable_global_exists("table_left") ? global.table_left : 210;
    var _top = variable_global_exists("table_top") ? global.table_top : 140;
    var _right = variable_global_exists("table_right") ? global.table_right : 1070;
    var _bottom = variable_global_exists("table_bottom") ? global.table_bottom : 560;
    return { left: _left, top: _top, right: _right, bottom: _bottom };
}

function physics_ball_init() {
    physics_radius = 16;
    physics_friction = 0.045;
    physics_stop_speed = 0.08;
    physics_restitution = 0.96;
    physics_cushion_lock = 0;
    physics_pair_lock = ds_map_create();
    physics_rule_lock = ds_map_create();
    hspeed = 0;
    vspeed = 0;
    speed = 0;
}

function physics_ball_cleanup() {
    if (variable_instance_exists(id, "physics_pair_lock") && ds_exists(physics_pair_lock, ds_type_map)) {
        ds_map_destroy(physics_pair_lock);
    }
    if (variable_instance_exists(id, "physics_rule_lock") && ds_exists(physics_rule_lock, ds_type_map)) {
        ds_map_destroy(physics_rule_lock);
    }
}

function physics_ball_step() {
    if (physics_cushion_lock > 0) physics_cushion_lock -= 1;

    var _keys = ds_map_keys_to_array(physics_pair_lock);
    for (var _i = 0; _i < array_length(_keys); _i++) {
        var _key = _keys[_i];
        physics_pair_lock[? _key] -= 1;
        if (physics_pair_lock[? _key] <= 0) ds_map_delete(physics_pair_lock, _key);
    }
    _keys = ds_map_keys_to_array(physics_rule_lock);
    for (var _j = 0; _j < array_length(_keys); _j++) {
        var _rule_key = _keys[_j];
        physics_rule_lock[? _rule_key] -= 1;
        if (physics_rule_lock[? _rule_key] <= 0) ds_map_delete(physics_rule_lock, _rule_key);
    }

    var _vx = hspeed;
    var _vy = vspeed;
    var _magnitude = point_distance(0, 0, _vx, _vy);
    if (_magnitude <= physics_stop_speed) {
        hspeed = 0;
        vspeed = 0;
        speed = 0;
    } else {
        var _next = max(0, _magnitude - physics_friction);
        var _scale = _next / _magnitude;
        hspeed = _vx * _scale;
        vspeed = _vy * _scale;
    }

    physics_resolve_table_bounds();
    physics_scan_ball_collisions();
}

function physics_begin_rule_contact(_other) {
    var _key = string(_other.id);
    if (ds_map_exists(physics_rule_lock, _key)) return false;
    physics_rule_lock[? _key] = 30;
    return true;
}

function physics_scan_ball_collisions() {
    var _owner = id;
    with (obj_ball) {
        if (id != _owner && point_distance(x, y, _owner.x, _owner.y) <= physics_radius + _owner.physics_radius) {
            var _candidate = id;
            with (_owner) {
                physics_resolve_ball_collision(_candidate);

                var _striker_here = (story_versus_active())
                    ? story_versus_striker_counts_cushions(_owner)
                    : (_owner.object_index == obj_ball_player);
                if (_striker_here && physics_begin_rule_contact(_candidate)) {
                    if (_candidate.object_index == obj_ball_target) {
                        if (rules_on_target_hit(_owner, _candidate, _owner.cushion_count) && !global.shot_penalized && !global.score_gain_fx.active) audio_sfx("snd_payout", 0.7);
                    } else if (_candidate.object_index == obj_ball_foul) {
                        if (!story_versus_break_foul_rules_suppressed()
                            && rules_on_foul_hit(_owner, _candidate))
                            audio_sfx(global.risk_shot_active ? "snd_risk_wipe" : "snd_foul", 0.95);
                    }
                } else if (_candidate.object_index == obj_ball_player || _candidate.object_index == obj_ball_ai) {
                    with (_candidate) {
                        var _striker_there = (story_versus_active())
                            ? story_versus_striker_counts_cushions(id)
                            : (object_index == obj_ball_player);
                        if (_striker_there && physics_begin_rule_contact(_owner)) {
                            if (_owner.object_index == obj_ball_target) {
                                if (rules_on_target_hit(id, _owner, cushion_count) && !global.shot_penalized && !global.score_gain_fx.active) audio_sfx("snd_payout", 0.7);
                            } else if (_owner.object_index == obj_ball_foul) {
                                if (!story_versus_break_foul_rules_suppressed()
                                    && rules_on_foul_hit(id, _owner))
                                    audio_sfx(global.risk_shot_active ? "snd_risk_wipe" : "snd_foul", 0.95);
                            }
                        }
                    }
                }
            }
        }
    }
}

function physics_can_place_ball(_ball, _x, _y) {
    if (!instance_exists(_ball)) return false;
    var _bounds = physics_table_bounds();
    var _radius = _ball.physics_radius;
    if (_x < _bounds.left + _radius || _x > _bounds.right - _radius) return false;
    if (_y < _bounds.top + _radius || _y > _bounds.bottom - _radius) return false;

    var _valid = true;
    with (obj_ball) {
        if (id != _ball && point_distance(x, y, _x, _y) < physics_radius + _radius + 2) {
            _valid = false;
        }
    }
    return _valid;
}

function physics_resolve_table_bounds() {
    var _bounds = physics_table_bounds();
    var _hit = false;

    if (x - physics_radius < _bounds.left) {
        x = _bounds.left + physics_radius;
        hspeed = abs(hspeed) * physics_restitution;
        _hit = true;
    } else if (x + physics_radius > _bounds.right) {
        x = _bounds.right - physics_radius;
        hspeed = -abs(hspeed) * physics_restitution;
        _hit = true;
    }

    if (y - physics_radius < _bounds.top) {
        y = _bounds.top + physics_radius;
        vspeed = abs(vspeed) * physics_restitution;
        _hit = true;
    } else if (y + physics_radius > _bounds.bottom) {
        y = _bounds.bottom - physics_radius;
        vspeed = -abs(vspeed) * physics_restitution;
        _hit = true;
    }

    if (_hit && physics_cushion_lock <= 0) {
        physics_cushion_lock = 3;
        var _counts = (story_versus_active()) ? story_versus_striker_counts_cushions(id) : (object_index == obj_ball_player);
        if (_counts) {
            if (!variable_global_exists("shot_scored") || !global.shot_scored) {
                cushion_count += 1;
                if (rules_on_cushion_hit(id, cushion_count)) audio_sfx("snd_cushion", 0.42, audio_cushion_pitch(cushion_count));
            }
        }
    }
    return _hit;
}

function physics_resolve_cushion_collision(_cushion) {
    if (physics_cushion_lock > 0) return false;

    var _horizontal = _cushion.orientation == "horizontal";
    if (_horizontal) {
        vspeed = -vspeed * physics_restitution;
    } else {
        hspeed = -hspeed * physics_restitution;
    }
    physics_cushion_lock = 3;
    return true;
}

function physics_resolve_ball_collision(_other) {
    if (!instance_exists(_other) || _other.id == id) return false;

    var _key = string(_other.id);
    if (ds_map_exists(physics_pair_lock, _key)) return false;

    var _dx = _other.x - x;
    var _dy = _other.y - y;
    var _distance = point_distance(x, y, _other.x, _other.y);
    var _minimum = physics_radius + _other.physics_radius;
    if (_distance <= 0) {
        _dx = 1;
        _dy = 0;
        _distance = 1;
    }

    var _nx = _dx / _distance;
    var _ny = _dy / _distance;
    var _overlap = _minimum - _distance;
    if (_overlap > 0) {
        x -= _nx * _overlap * 0.5;
        y -= _ny * _overlap * 0.5;
        _other.x += _nx * _overlap * 0.5;
        _other.y += _ny * _overlap * 0.5;
    }

    var _relative_normal = (hspeed - _other.hspeed) * _nx + (vspeed - _other.vspeed) * _ny;
    if (_relative_normal <= 0) return false;

    var _impulse = _relative_normal * min(physics_restitution, _other.physics_restitution);
    hspeed -= _impulse * _nx;
    vspeed -= _impulse * _ny;
    _other.hspeed += _impulse * _nx;
    _other.vspeed += _impulse * _ny;

    physics_pair_lock[? _key] = 3;
    _other.physics_pair_lock[? string(id)] = 3;
    return true;
}

function physics_all_balls_stopped() {
    var _stopped = true;
    with (obj_ball) {
        if (point_distance(0, 0, hspeed, vspeed) > physics_stop_speed) {
            _stopped = false;
        }
    }
    return _stopped;
}

function physics_shoot(_ball, _direction, _power) {
    if (!instance_exists(_ball) || _power <= 0 || !physics_all_balls_stopped()) return false;
    if (story_versus_active()) {
        if (!story_versus_on_shot_started(_ball)) return false;
    } else if (!rules_on_shot_started(_ball)) return false;
    _ball.cushion_count = 0;
    _ball.hspeed = lengthdir_x(_power, _direction);
    _ball.vspeed = lengthdir_y(_power, _direction);
    audio_sfx("snd_shot", 0.65);
    return true;
}

/// In-game AI shot selection: 2-5 cushion candidates, score / foul risk heuristic.

#macro STORY_AI_MIN_CUSHIONS 2
#macro STORY_AI_MAX_CUSHIONS 5
#macro STORY_AI_SIM_MAX_STEPS 720

function story_ai_difficulty_tier() {
    if (!story_versus_is_fifty_round_match()) return 1;
    if (variable_global_exists("story_break_pending") && global.story_break_pending) return 1;
    var _round = story_versus_current_round_number();
    if (_round <= 0) return 1;
    var _player_lead = global.story_player_score - global.story_ai_score;
    if (_round <= 10 && _player_lead < STORY_AI_SOFT_LEAD_END) return 0;
    if (_round >= 40) return 2;
    return 1;
}

function story_ai_ball_snapshot() {
    var _balls = [];
    with (obj_ball) {
        var _kind = "other";
        if (object_index == obj_ball_player) _kind = "player";
        else if (object_index == obj_ball_ai) _kind = "ai";
        else if (object_index == obj_ball_target) _kind = "target";
        else if (object_index == obj_ball_foul) _kind = "foul";
        array_push(_balls, {
            kind: _kind,
            x: x,
            y: y,
            vx: hspeed,
            vy: vspeed,
            r: physics_radius
        });
    }
    return _balls;
}

function story_ai_sim_resolve_bounds(_b, _bounds) {
    var _hit = false;
    if (_b.x - _b.r < _bounds.left) {
        _b.x = _bounds.left + _b.r;
        _b.vx = abs(_b.vx) * 0.96;
        _hit = true;
    } else if (_b.x + _b.r > _bounds.right) {
        _b.x = _bounds.right - _b.r;
        _b.vx = -abs(_b.vx) * 0.96;
        _hit = true;
    }
    if (_b.y - _b.r < _bounds.top) {
        _b.y = _bounds.top + _b.r;
        _b.vy = abs(_b.vy) * 0.96;
        _hit = true;
    } else if (_b.y + _b.r > _bounds.bottom) {
        _b.y = _bounds.bottom - _b.r;
        _b.vy = -abs(_b.vy) * 0.96;
        _hit = true;
    }
    return _hit;
}

function story_ai_sim_ball_pair(_a, _b) {
    var _dx = _b.x - _a.x;
    var _dy = _b.y - _a.y;
    var _dist = point_distance(_a.x, _a.y, _b.x, _b.y);
    var _min = _a.r + _b.r;
    if (_dist >= _min) return false;
    if (_dist <= 0) {
        _dx = 1;
        _dy = 0;
        _dist = 1;
    }
    var _nx = _dx / _dist;
    var _ny = _dy / _dist;
    var _overlap = _min - _dist;
    _a.x -= _nx * _overlap * 0.5;
    _a.y -= _ny * _overlap * 0.5;
    _b.x += _nx * _overlap * 0.5;
    _b.y += _ny * _overlap * 0.5;
    var _rel = (_a.vx - _b.vx) * _nx + (_a.vy - _b.vy) * _ny;
    if (_rel <= 0) return false;
    var _imp = _rel * 0.96;
    _a.vx -= _imp * _nx;
    _a.vy -= _imp * _ny;
    _b.vx += _imp * _nx;
    _b.vy += _imp * _ny;
    return true;
}

function story_ai_simulate_shot(_dir, _power) {
    var _balls = story_ai_ball_snapshot();
    return story_ai_simulate_shot_from_balls(_balls, _dir, _power);
}

function story_ai_dist_to_segment(_px, _py, _x1, _y1, _x2, _y2) {
    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
    var _len2 = _dx * _dx + _dy * _dy;
    if (_len2 <= 0) return point_distance(_px, _py, _x1, _y1);
    var _t = clamp(((_px - _x1) * _dx + (_py - _y1) * _dy) / _len2, 0, 1);
    return point_distance(_px, _py, _x1 + _t * _dx, _y1 + _t * _dy);
}

function story_ai_ray_foul_risk(_x, _y, _dir) {
    var _risk = 0;
    var _len = 900;
    var _ex = _x + lengthdir_x(_len, _dir);
    var _ey = _y + lengthdir_y(_len, _dir);
    with (obj_ball_foul) {
        var _d = story_ai_dist_to_segment(x, y, _x, _y, _ex, _ey);
        if (_d < 40) _risk += 1 - (_d / 40);
    }
    return clamp(_risk, 0, 1);
}

/// Fixed layout mirror of story_versus_spawn_layout(); used by static/runtime self-check.
function story_ai_fixture_ball_snapshot() {
    return [
        { kind: "player", x: 380, y: 350, vx: 0, vy: 0, r: 16 },
        { kind: "ai", x: 900, y: 350, vx: 0, vy: 0, r: 16 },
        { kind: "target", x: 640, y: 260, vx: 0, vy: 0, r: 16 },
        { kind: "foul", x: 520, y: 480, vx: 0, vy: 0, r: 16 },
        { kind: "foul", x: 760, y: 480, vx: 0, vy: 0, r: 16 }
    ];
}

function story_ai_simulate_shot_from_balls(_balls, _dir, _power) {
    var _striker = -1;
    for (var _i = 0; _i < array_length(_balls); _i++) {
        if (_balls[_i].kind == "ai") {
            _striker = _i;
            _balls[_i].vx = lengthdir_x(_power, _dir);
            _balls[_i].vy = lengthdir_y(_power, _dir);
        } else {
            _balls[_i].vx = 0;
            _balls[_i].vy = 0;
        }
    }
    if (_striker < 0) return noone;

    var _bounds = physics_table_bounds();
    var _cushions = 0;
    var _hit_target = false;
    var _foul = false;
    var _stop = 0.08;
    var _friction = 0.045;

    for (var _step = 0; _step < STORY_AI_SIM_MAX_STEPS; _step++) {
        var _moving = false;
        for (var _b = 0; _b < array_length(_balls); _b++) {
            var _mag = point_distance(0, 0, _balls[_b].vx, _balls[_b].vy);
            if (_mag > _stop) {
                _moving = true;
                var _next = max(0, _mag - _friction);
                var _scale = _next / _mag;
                _balls[_b].vx *= _scale;
                _balls[_b].vy *= _scale;
            } else {
                _balls[_b].vx = 0;
                _balls[_b].vy = 0;
            }
            _balls[_b].x += _balls[_b].vx;
            _balls[_b].y += _balls[_b].vy;
        }
        if (!_moving) break;

        for (var _bi = 0; _bi < array_length(_balls); _bi++) {
            if (story_ai_sim_resolve_bounds(_balls[_bi], _bounds) && _bi == _striker && !_hit_target && !_foul) {
                _cushions += 1;
            }
        }

        for (var _i2 = 0; _i2 < array_length(_balls); _i2++) {
            for (var _j = _i2 + 1; _j < array_length(_balls); _j++) {
                if (point_distance(_balls[_i2].x, _balls[_i2].y, _balls[_j].x, _balls[_j].y) <= _balls[_i2].r + _balls[_j].r) {
                    story_ai_sim_ball_pair(_balls[_i2], _balls[_j]);
                    if (_i2 == _striker || _j == _striker) {
                        var _other = (_i2 == _striker) ? _balls[_j] : _balls[_i2];
                        // A foul voids the shot even when it happens after the target hit.
                        if (_other.kind == "foul") _foul = true;
                        if (!_hit_target && !_foul && _other.kind == "target") _hit_target = true;
                    }
                }
            }
        }
    }

    return {
        cushions: _cushions,
        hit_target: _hit_target,
        foul: _foul,
        expected_score: (_hit_target && !_foul) ? story_versus_points_for_cushions(_cushions) : 0
    };
}

function story_ai_fixture_has_valid_candidate() {
    var _powers = [6, 9, 12, 15, 18];
    for (var _dir = 0; _dir < 360; _dir += 6) {
        for (var _p = 0; _p < array_length(_powers); _p++) {
            var _balls = story_ai_fixture_ball_snapshot();
            var _sim = story_ai_simulate_shot_from_balls(_balls, _dir, _powers[_p]);
            if (_sim == noone) continue;
            if (_sim.foul || !_sim.hit_target) continue;
            if (_sim.cushions >= STORY_AI_MIN_CUSHIONS && _sim.cushions <= STORY_AI_MAX_CUSHIONS) return true;
        }
    }
    return false;
}

function story_ai_pick_shot() {
    var _ai = instance_find(obj_ball_ai, 0);
    if (!instance_exists(_ai)) return noone;

    var _found = false;
    var _best_dir = 0;
    var _best_power = 0;
    var _best_cushions = 0;
    var _best_score = 0;
    var _best_value = -1000000000;
    var _fallback_dir = 0;
    var _fallback_power = 9;
    var _fallback_value = -1000000000;
    var _fallback_cushions = 0;
    var _fallback_score = 0;
    var _powers = [6, 9, 12, 15, 18];
    var _minimum_cushions = story_versus_stage_min_cushions();
    var _tier = story_ai_difficulty_tier();
    var _foul_weight = (_tier == 2) ? 120 : 250;
    var _need_samples = (_tier == 0) ? 1 : 3;

    for (var _dir = 0; _dir < 360; _dir += 6) {
        for (var _p = 0; _p < array_length(_powers); _p++) {
            var _sim = story_ai_simulate_shot(_dir, _powers[_p]);
            if (_sim == noone) continue;
            // Always retain a playable shot. Small changes in the live table can
            // leave the strict multi-sample search without a scoring candidate.
            var _fallback_points = (!_sim.foul && _sim.hit_target && _sim.cushions >= _minimum_cushions)
                ? _sim.expected_score : 0;
            var _fallback_rank = _fallback_points - (_sim.foul ? 100000 : 0)
                - story_ai_ray_foul_risk(_ai.x, _ai.y, _dir) * _foul_weight;
            if (_tier == 0) _fallback_rank = -_fallback_points - story_ai_ray_foul_risk(_ai.x, _ai.y, _dir) * 40;
            if (_fallback_rank > _fallback_value) {
                _fallback_value = _fallback_rank;
                _fallback_dir = _dir;
                _fallback_power = _powers[_p];
                _fallback_cushions = _sim.cushions;
                _fallback_score = _fallback_points;
            }
            if (_sim.foul) continue;
            if (!_sim.hit_target) continue;
            if (_sim.cushions < max(STORY_AI_MIN_CUSHIONS, _minimum_cushions)
                || _sim.cushions > STORY_AI_MAX_CUSHIONS) continue;

            // Nearby aim samples estimate whether this path survives small
            // differences between the planner and live collision timing.
            var _angle_offsets = [-1, -0.5, 0, 0.5, 1];
            var _valid_samples = 0;
            var _score_sum = 0;
            for (var _sample = 0; _sample < array_length(_angle_offsets); _sample++) {
                var _near = (_angle_offsets[_sample] == 0)
                    ? _sim : story_ai_simulate_shot(_dir + _angle_offsets[_sample], _powers[_p]);
                if (_near != noone && !_near.foul && _near.hit_target
                    && _near.cushions >= STORY_AI_MIN_CUSHIONS && _near.cushions <= STORY_AI_MAX_CUSHIONS) {
                    _valid_samples += 1;
                    _score_sum += _near.expected_score;
                }
            }
            if (_valid_samples < _need_samples) continue;
            var _foul_risk = story_ai_ray_foul_risk(_ai.x, _ai.y, _dir);
            var _avg_score = _score_sum / array_length(_angle_offsets);
            var _value = (_tier == 0)
                ? (-_avg_score - _foul_risk * 40)
                : (_avg_score - _foul_risk * _foul_weight);

            if (_value > _best_value) {
                _found = true;
                _best_value = _value;
                _best_dir = _dir;
                _best_power = _powers[_p];
                _best_cushions = _sim.cushions;
                _best_score = _sim.expected_score;
            }
        }
    }
    if (!_found) return { direction: _fallback_dir, power: _fallback_power,
        cushions: _fallback_cushions, expected_score: _fallback_score };
    return { direction: _best_dir, power: _best_power, cushions: _best_cushions, expected_score: _best_score };
}

function story_ai_execute_turn() {
    if (!story_versus_is_ai_turn() || !physics_all_balls_stopped()) return false;
    if (global.story_stage_clear_pending) return false;
    var _ai = instance_find(obj_ball_ai, 0);
    if (!instance_exists(_ai)) {
        global.story_last_ai_pass = true;
        story_versus_pass_turn_no_shot("AI PASS (NO BALL)");
        return false;
    }
    if (variable_global_exists("story_break_pending") && global.story_break_pending
        && global.story_turn == STORY_TURN_AI) {
        var _target = instance_find(obj_ball_target, 0);
        if (!instance_exists(_target)) {
            global.story_last_ai_pass = true;
            story_versus_pass_turn_no_shot("AI PASS (NO TARGET)");
            return false;
        }
        randomize();
        var _break_side = (irandom(1) == 0) ? -1 : 1;
        var _break_direction = point_direction(_ai.x, _ai.y, _target.x, _target.y)
            + _break_side * random_range(5, 6);
        var _break_power = random_range(26, 30);
        var _player_risk_for_break = global.risk_shot_armed;
        global.risk_shot_armed = false;
        var _break_shot = physics_shoot(_ai, _break_direction, _break_power);
        global.risk_shot_armed = _player_risk_for_break;
        if (_break_shot) {
            global.story_last_ai_cushions = -1;
        } else {
            global.story_last_ai_pass = true;
            story_versus_pass_turn_no_shot("AI PASS (BREAK)");
        }
        return _break_shot;
    }
    var _pick = story_ai_pick_shot();
    if (_pick == noone) {
        global.story_last_ai_pass = true;
        global.story_last_ai_cushions = -1;
        story_versus_pass_turn_no_shot("AI PASS (NO SHOT)");
        return false;
    }
    global.story_last_ai_cushions = _pick.cushions;
    var _tier = story_ai_difficulty_tier();
    var _shot_dir = _pick.direction + ((_tier == 0) ? random_range(-5, 5) : 0);
    // The player's purchased risk shot is pending across turns. Keep the AI
    // from consuming it; contract stages give the bartender its own risk shot.
    var _player_risk_armed = global.risk_shot_armed;
    global.risk_shot_armed = story_versus_stage_risk_contract();
    var _shot = physics_shoot(_ai, _shot_dir, _pick.power);
    global.risk_shot_armed = _player_risk_armed;
    if (!_shot) {
        global.story_last_ai_pass = true;
        story_versus_pass_turn_no_shot("AI PASS (SHOT FAILED)");
        return false;
    }
    global.story_ai_shot_was_gentle = (_tier == 0);
    return _shot;
}

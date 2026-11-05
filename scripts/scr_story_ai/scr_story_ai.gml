/// In-game AI shot selection: uncapped cushion candidates, score-gap / foul-risk heuristic.

#macro STORY_AI_MIN_CUSHIONS 2
#macro STORY_AI_SIM_MAX_STEPS 720
#macro STORY_AI_ITEM_AGGRO_LEAD 3200
#macro STORY_AI_RISK_LEAD 100000
#macro STORY_AI_COMPETITIVE_GAP 2000

function story_ai_difficulty_tier() {
    if (!story_versus_is_fifty_round_match()) return 1;
    if (variable_global_exists("story_break_pending") && global.story_break_pending) return 1;
    var _round = story_versus_current_round_number();
    if (_round <= 0) return 1;
    var _player_lead = global.story_player_score - global.story_ai_score;
    if (_round <= 10 && _player_lead < STORY_AI_COMPETITIVE_GAP) return 0;
    if (_round >= 40 || _player_lead >= STORY_AI_SOFT_LEAD_END) return 2;
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

function story_ai_expected_points(_sim) {
    if (_sim == noone || _sim.foul || !_sim.hit_target) return 0;
    if (!global.story_ai_risk_shot_armed) return _sim.expected_score;
    if (story_versus_is_fifty_round_match()) return story_risk_points_for_cushions(_sim.cushions);
    if (_sim.cushions <= 0) return 100;
    return (_sim.cushions == 1) ? 1000 : 10000;
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
            if (_sim.cushions >= STORY_AI_MIN_CUSHIONS) return true;
        }
    }
    return false;
}

/// Place the bartender's cue ball without entering the player's placement UI.
function story_ai_auto_place_ball() {
    var _ai = instance_find(obj_ball_ai, 0);
    var _target = instance_find(obj_ball_target, 0);
    if (!instance_exists(_ai) || !instance_exists(_target)) return false;
    var _bounds = physics_table_bounds();
    var _best_x = _ai.x;
    var _best_y = _ai.y;
    var _best_value = -1000000000;
    var _found = false;
    var _fouls = instance_number(obj_ball_foul);
    for (var _radius_index = 0; _radius_index < 2; _radius_index++) {
        var _distance = (_radius_index == 0) ? 170 : 250;
        for (var _angle = 0; _angle < 360; _angle += 30) {
            var _x = _target.x + lengthdir_x(_distance, _angle);
            var _y = _target.y + lengthdir_y(_distance, _angle);
            if (!physics_can_place_ball(_ai, _x, _y)) continue;
            if (point_distance(_x, _y, _ai.x, _ai.y) < 32) continue;
            var _clearance = min(_x - _bounds.left, _bounds.right - _x,
                _y - _bounds.top, _bounds.bottom - _y);
            var _foul_clearance = 300;
            for (var _i = 0; _i < _fouls; _i++) {
                var _foul = instance_find(obj_ball_foul, _i);
                if (instance_exists(_foul)) {
                    _foul_clearance = min(_foul_clearance,
                        point_distance(_x, _y, _foul.x, _foul.y));
                }
            }
            var _value = min(_clearance, 100) + min(_foul_clearance, 200) * 2;
            if (_value > _best_value) {
                _best_value = _value;
                _best_x = _x;
                _best_y = _y;
                _found = true;
            }
        }
    }
    if (!_found) return false;
    _ai.x = _best_x;
    _ai.y = _best_y;
    _ai.speed = 0;
    _ai.hspeed = 0;
    _ai.vspeed = 0;
    return true;
}

/// Returns true when the board changed and the shot should be planned again.
function story_ai_arm_recovery_risk_if_due() {
    if (!story_versus_is_fifty_round_match() || global.story_break_pending) return false;
    if (global.story_ai_recovery_risk_used || global.story_ai_recovery_risk_pending) return false;
    if (global.story_ai_recovery_due_pair < 0) return false;
    if (story_versus_current_round_number() < global.story_ai_recovery_due_pair) return false;
    if (!story_versus_purchase_item_for_side(STORY_TURN_AI, 2, true)) return false;
    global.story_ai_recovery_risk_pending = true;
    show_debug_message("STORY_AI_RECOVERY_RISK_TRIGGER hand="
        + string(global.story_completed_pairs + 1)
        + " ai=" + string(global.story_ai_score)
        + " player=" + string(global.story_player_score));
    return true;
}

function story_ai_pick_max_risk_shot() {
    var _ai = instance_find(obj_ball_ai, 0);
    if (!instance_exists(_ai)) return noone;
    var _was_armed = global.story_ai_risk_shot_armed;
    global.story_ai_risk_shot_armed = true;
    var _found = false;
    var _best_dir = 0;
    var _best_power = 9;
    var _best_cushions = 0;
    var _best_score = 0;
    var _powers = [6, 9, 12, 15, 18];
    var _minimum_cushions = story_versus_stage_min_cushions();
    for (var _dir = 0; _dir < 360; _dir += 6) {
        for (var _p = 0; _p < array_length(_powers); _p++) {
            var _sim = story_ai_simulate_shot(_dir, _powers[_p]);
            if (_sim == noone || _sim.foul || !_sim.hit_target) continue;
            if (_sim.cushions < max(STORY_AI_MIN_CUSHIONS, _minimum_cushions)) continue;
            var _points = story_ai_expected_points(_sim);
            if (_points > _best_score) {
                _found = true;
                _best_score = _points;
                _best_dir = _dir;
                _best_power = _powers[_p];
                _best_cushions = _sim.cushions;
            }
        }
    }
    global.story_ai_risk_shot_armed = _was_armed;
    if (!_found) return noone;
    return { direction: _best_dir, power: _best_power,
        cushions: _best_cushions, expected_score: _best_score };
}

/// Recovery risk: aim a live shot that the planner sim predicts will contact a foul ball.
function story_ai_pick_recovery_foul_shot() {
    if (instance_number(obj_ball_foul) <= 0) return noone;
    var _ai = instance_find(obj_ball_ai, 0);
    if (!instance_exists(_ai)) return noone;
    var _was_armed = global.story_ai_risk_shot_armed;
    global.story_ai_risk_shot_armed = true;
    var _found = false;
    var _best_dir = 0;
    var _best_power = 9;
    var _best_cushions = 0;
    var _best_value = -1000000000;
    var _powers = [6, 9, 12, 15, 18];
    var _angle_offsets = [-1, -0.5, 0, 0.5, 1];
    for (var _dir = 0; _dir < 360; _dir += 6) {
        for (var _p = 0; _p < array_length(_powers); _p++) {
            var _sim = story_ai_simulate_shot(_dir, _powers[_p]);
            if (_sim == noone || !_sim.foul) continue;
            var _foul_samples = 0;
            for (var _sample = 0; _sample < array_length(_angle_offsets); _sample++) {
                var _near = story_ai_simulate_shot(_dir + _angle_offsets[_sample], _powers[_p]);
                if (_near != noone && _near.foul) _foul_samples += 1;
            }
            if (_foul_samples < 3) continue;
            var _value = _foul_samples * 1000;
            if (!_sim.hit_target) _value += 5000;
            else _value -= story_ai_expected_points(_sim);
            if (_value > _best_value) {
                _found = true;
                _best_value = _value;
                _best_dir = _dir;
                _best_power = _powers[_p];
                _best_cushions = _sim.cushions;
            }
        }
    }
    global.story_ai_risk_shot_armed = _was_armed;
    if (!_found) return noone;
    return { direction: _best_dir, power: _best_power,
        cushions: _best_cushions, expected_score: 0 };
}

function story_ai_fixture_has_recovery_foul_shot() {
    var _powers = [6, 9, 12, 15, 18];
    for (var _dir = 0; _dir < 360; _dir += 6) {
        for (var _p = 0; _p < array_length(_powers); _p++) {
            var _balls = story_ai_fixture_ball_snapshot();
            var _sim = story_ai_simulate_shot_from_balls(_balls, _dir, _powers[_p]);
            if (_sim != noone && _sim.foul) return true;
        }
    }
    return false;
}

/// Returns true when the board changed and the shot should be planned again.
function story_ai_consider_items(_pick) {
    if (story_ai_difficulty_tier() == 0 || global.story_break_pending) return false;
    if (variable_global_exists("story_item_used_this_turn") && global.story_item_used_this_turn) return false;
    var _lead = global.story_player_score - global.story_ai_score;
    var _aggressive = (_lead >= STORY_AI_ITEM_AGGRO_LEAD);
    var _low_score = (_pick == noone || _pick.expected_score < (_aggressive ? 800 : 400));
    var _ai = instance_find(obj_ball_ai, 0);
    var _bounds = physics_table_bounds();
    var _near_wall = instance_exists(_ai)
        && min(_ai.x - _bounds.left, _bounds.right - _ai.x,
            _ai.y - _bounds.top, _bounds.bottom - _ai.y) < 90;
    var _foul_blocks_shot = instance_number(obj_ball_foul) > 0
        && instance_exists(_ai) && _pick != noone
        && _low_score && story_ai_ray_foul_risk(_ai.x, _ai.y, _pick.direction) >= 0.35;

    if (_foul_blocks_shot
        && story_versus_purchase_item_for_side(STORY_TURN_AI, 3)) return true;
    if (_low_score && _near_wall
        && story_versus_purchase_item_for_side(STORY_TURN_AI, 1)) return true;
    if (_lead >= STORY_AI_RISK_LEAD && global.story_ai_score >= 3200) {
        if (story_versus_purchase_item_for_side(STORY_TURN_AI, 2)) return true;
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
    if (_tier == 0) _powers = [6, 9, 12];
    var _foul_weight = (_tier == 2) ? 400 : 250;
    var _player_lead = global.story_player_score - global.story_ai_score;
    var _competitive = story_versus_is_fifty_round_match();
    var _need_samples = (_tier == 0) ? 1
        : ((_competitive && _player_lead >= STORY_AI_COMPETITIVE_GAP) ? 2 : 3);
    var _soft_candidates = [];

    for (var _dir = 0; _dir < 360; _dir += 6) {
        for (var _p = 0; _p < array_length(_powers); _p++) {
            var _sim = story_ai_simulate_shot(_dir, _powers[_p]);
            if (_sim == noone) continue;
            // Always retain a playable shot. Small changes in the live table can
            // leave the strict multi-sample search without a scoring candidate.
            var _fallback_points = (_sim.cushions >= _minimum_cushions)
                ? story_ai_expected_points(_sim) : 0;
            var _fallback_rank = _fallback_points - (_sim.foul ? 100000 : 0)
                - story_ai_ray_foul_risk(_ai.x, _ai.y, _dir) * _foul_weight;
            if (_tier == 0) _fallback_rank = _fallback_points - story_ai_ray_foul_risk(_ai.x, _ai.y, _dir) * 40;
            else if (_competitive) {
                var _fallback_gap = abs(global.story_ai_score + _fallback_points - global.story_player_score);
                _fallback_rank = -2 * max(0, _fallback_gap - STORY_AI_COMPETITIVE_GAP)
                    + 0.5 * min(_fallback_points, STORY_AI_COMPETITIVE_GAP)
                    - (_sim.foul ? 100000 : 0)
                    - story_ai_ray_foul_risk(_ai.x, _ai.y, _dir) * _foul_weight;
            }
            if (_fallback_rank > _fallback_value) {
                _fallback_value = _fallback_rank;
                _fallback_dir = _dir;
                _fallback_power = _powers[_p];
                _fallback_cushions = _sim.cushions;
                _fallback_score = _fallback_points;
            }
            if (_sim.foul) continue;
            if (!_sim.hit_target) continue;
            if (_sim.cushions < max(STORY_AI_MIN_CUSHIONS, _minimum_cushions)) continue;

            // Nearby aim samples estimate whether this path survives small
            // differences between the planner and live collision timing.
            var _angle_offsets = [-1, -0.5, 0, 0.5, 1];
            var _valid_samples = 0;
            var _score_sum = 0;
            for (var _sample = 0; _sample < array_length(_angle_offsets); _sample++) {
                var _near = (_angle_offsets[_sample] == 0)
                    ? _sim : story_ai_simulate_shot(_dir + _angle_offsets[_sample], _powers[_p]);
                if (_near != noone && !_near.foul && _near.hit_target
                    && _near.cushions >= STORY_AI_MIN_CUSHIONS) {
                    _valid_samples += 1;
                    _score_sum += story_ai_expected_points(_near);
                }
            }
            if (_valid_samples < _need_samples) continue;
            var _foul_risk = story_ai_ray_foul_risk(_ai.x, _ai.y, _dir);
            var _avg_score = _score_sum / array_length(_angle_offsets);
            var _value = _avg_score - _foul_risk * ((_tier == 0) ? 40 : _foul_weight);
            if (_tier != 0 && _competitive) {
                var _after_gap = abs(global.story_ai_score + story_ai_expected_points(_sim)
                    - global.story_player_score);
                var _outside_band = max(0, _after_gap - STORY_AI_COMPETITIVE_GAP);
                _value = -2 * _outside_band + 0.5 * min(_avg_score, STORY_AI_COMPETITIVE_GAP)
                    + 100 * _valid_samples - _foul_risk * _foul_weight;
            }
            else if (_tier == 2) _value += 100 * max(0, _sim.cushions - 1);

            if (_tier == 0) {
                array_push(_soft_candidates, { direction: _dir, power: _powers[_p],
                    cushions: _sim.cushions, expected_score: story_ai_expected_points(_sim), rank: _value });
                continue;
            }

            if (_value > _best_value) {
                _found = true;
                _best_value = _value;
                _best_dir = _dir;
                _best_power = _powers[_p];
                _best_cushions = _sim.cushions;
                _best_score = story_ai_expected_points(_sim);
            }
        }
    }
    if (_tier == 0 && array_length(_soft_candidates) > 0) {
        array_sort(_soft_candidates, function(_a, _b) { return _b.rank - _a.rank; });
        var _choice = min(array_length(_soft_candidates) - 1, irandom_range(1, 3));
        return _soft_candidates[_choice];
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
        var _ai_risk_for_break = global.story_ai_risk_shot_armed;
        global.story_ai_risk_shot_armed = false;
        var _break_shot = physics_shoot(_ai, _break_direction, _break_power);
        global.story_ai_risk_shot_armed = _ai_risk_for_break;
        if (_break_shot) {
            global.story_last_ai_cushions = -1;
        } else {
            global.story_last_ai_pass = true;
            story_versus_pass_turn_no_shot("AI PASS (BREAK)");
        }
        return _break_shot;
    }
    story_ai_arm_recovery_risk_if_due();
    var _pick = global.story_ai_recovery_risk_pending
        ? story_ai_pick_recovery_foul_shot() : story_ai_pick_shot();
    if (_pick == noone && global.story_ai_recovery_risk_pending) {
        global.story_ai_recovery_risk_pending = false;
        global.story_ai_risk_shot_armed = false;
        global.story_ai_score = story_score_add(global.story_ai_score,
            story_versus_item_price(2, STORY_TURN_AI));
        global.story_item_used_this_turn = false;
        global.story_ai_item_use_counts[1] -= 1;
        global.story_last_ai_pass = true;
        global.story_last_ai_cushions = -1;
        story_versus_pass_turn_no_shot("AI PASS (NO RISK SHOT)");
        return false;
    }
    if (!global.story_ai_recovery_risk_pending && story_ai_consider_items(_pick))
        _pick = story_ai_pick_shot();
    if (_pick == noone) {
        global.story_last_ai_pass = true;
        global.story_last_ai_cushions = -1;
        story_versus_pass_turn_no_shot("AI PASS (NO SHOT)");
        return false;
    }
    global.story_last_ai_cushions = _pick.cushions;
    var _tier = story_ai_difficulty_tier();
    var _shot_dir = _pick.direction;
    if (_tier == 0 && !global.story_ai_recovery_risk_pending)
        _shot_dir += random_range(-6, 6);
    if (global.story_ai_recovery_risk_pending) {
        show_debug_message("STORY_AI_RECOVERY_RISK_SHOT dir=" + string(_shot_dir)
            + " power=" + string(_pick.power)
            + " sim_foul=" + string(story_ai_simulate_shot(_shot_dir, _pick.power).foul));
    }
    var _ai_risk_armed = global.story_ai_risk_shot_armed;
    var _shot = physics_shoot(_ai, _shot_dir, _pick.power);
    if (!_shot) global.story_ai_risk_shot_armed = _ai_risk_armed;
    if (!_shot) {
        if (global.story_ai_recovery_risk_pending) {
            global.story_ai_recovery_risk_pending = false;
            global.story_ai_risk_shot_armed = false;
            global.story_ai_score = story_score_add(global.story_ai_score,
                story_versus_item_price(2, STORY_TURN_AI));
            global.story_item_used_this_turn = false;
            global.story_ai_item_use_counts[1] -= 1;
        }
        global.story_last_ai_pass = true;
        story_versus_pass_turn_no_shot("AI PASS (SHOT FAILED)");
        return false;
    }
    global.story_ai_shot_was_gentle = (_tier == 0);
    return _shot;
}

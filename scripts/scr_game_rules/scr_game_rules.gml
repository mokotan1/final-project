/// Pure game-rule state. The best score persists through cushion_foul_void_save.ini.
/// High-risk item: arms the next shot for exponential cushion scoring.

#macro ENDLESS_SCORE_MAX 999999999

function rules_item_move() { return 1; }
function rules_item_risk_shot() { return 2; }
function rules_item_remove_foul() { return 3; }

function rules_item_name(_item) {
    switch (_item) {
        case 1: return tr("Move", "공 이동");
        case 2: return tr("Risk Shot", "할 수 있다 나라면!!");
        case 3: return tr("Remove foul", "겁쟁이들의 쉼터");
    }
    return tr("Unknown", "알 수 없음");
}

function rules_init(_preserve_best = true) {
    game_mode_ensure();
    // Normal game rooms must clear story-only state before obj_cue starts
    // reading turn state. This also makes returning from STORY deterministic.
    global.story_versus_active = false;
    global.story_match_over = false;
    var _best = game_mode_load_best_score();
    if (_preserve_best && variable_global_exists("best_score")) {
        _best = global.best_score;
    }

    global.score = 0;
    global.chances = 3;
    global.best_score = _best;
    global.item_meter = 0;
    global.item_goal = 3;
    global.milestone_index = 0;
    global.pending_reward_choice = false;
    global.pending_reward_queue = [];
    global.pending_reward_foul_queue = [];
    global.reward_choice_open = false;
    global.shot_loss_reason = "";
    global.shot_loss_timer = 0;
    global.new_best_shown = false;
    global.new_best_timer = 0;
    global.best_save_failed = false;
    global.foul_count = 1;
    global.inventory = [];
    global.balls_moving = false;
    global.place_mode = true;
    global.place_from_item = false;
    global.game_over = false;

    global.shot_active = false;
    global.shot_cushion_count = 0;
    global.shot_scored = false;
    global.shot_penalized = false;
    global.shot_last_foul = noone;
    global.shot_pending_points = 0;
    global.zero_cushion_streak = 0;
    global.score_void_fx = { active: false, from: 0, x: 0, y: 0, age: 0, life: 48 };
    global.score_gain_fx = { active: false, from: 0, gain: 0, age: 0, life: 150 };
    global.game_over_delay = 0;
    global.cushion_fx = [];
    global.payout_fx = [];

    global.risk_shot_armed = false;
    global.risk_shot_active = false;
    global.pending_foul_spawns = 0;
    global.spawn_retry_armed = false;
    global.classic_foul_progress = 0;
    global.classic_foul_goal_index = 0;
}

function rules_milestone_item(_index) {
    switch (_index) {
        case 0: return rules_item_move();
        case 1: return rules_item_remove_foul();
        case 2: return rules_item_risk_shot();
    }
    return -1;
}

function rules_next_goal() {
    return global.item_goal;
}

function rules_on_shot_started(_player_ball) {
    if (story_versus_active()) return story_versus_on_shot_started(_player_ball);
    if (global.game_over || global.shot_active || global.place_mode || global.pending_reward_choice || global.reward_choice_open) return false;

    global.shot_active = true;
    global.balls_moving = true;
    global.shot_cushion_count = 0;
    global.shot_scored = false;
    global.shot_penalized = false;
    global.shot_last_foul = noone;
    global.shot_pending_points = 0;
    global.score_void_fx.active = false;
    global.score_gain_fx.active = false;
    global.shot_loss_reason = "";
    global.shot_loss_timer = 0;
    global.risk_shot_active = global.risk_shot_armed;
    global.risk_shot_armed = false;
    return true;
}

function rules_on_cushion_hit(_player_ball, _cushion_count) {
    if (story_versus_active()) return story_versus_on_cushion_hit(_player_ball, _cushion_count);
    if (!global.shot_active || global.game_over) return false;
    if (global.shot_scored || global.shot_penalized) return false;
    if (_cushion_count <= global.shot_cushion_count) return false;
    global.shot_cushion_count = max(global.shot_cushion_count, _cushion_count);
    array_push(global.cushion_fx, {
        x: _player_ball.x,
        y: _player_ball.y,
        count: _cushion_count,
        risk: global.risk_shot_active,
        age: 0,
        // Keep the hit callout readable through a full billiards exchange;
        // Draw_64 holds the label, then fades it over the remaining frames.
        life: 84
    });
    return true;
}

function rules_on_target_hit(_player_ball, _target_ball, _cushion_count) {
    if (story_versus_active()) return story_versus_on_target_hit(_player_ball, _target_ball, _cushion_count);
    if (!global.shot_active || global.game_over || global.shot_scored) return false;

    global.shot_cushion_count = max(global.shot_cushion_count, _cushion_count);
    global.shot_scored = true;
    // The third consecutive clean zero-cushion shot starts a 30-point drop per shot.
    // Cushion hits double ordinary scoring or multiply Risk Shot scoring by ten.
    var _gain = global.shot_cushion_count == 0
        ? max(0, 100 - 30 * max(0, global.zero_cushion_streak - 1))
        : (global.risk_shot_active
            ? 100 * power(10, global.shot_cushion_count)
            : 100 * power(2, global.shot_cushion_count));
    if (!global.shot_penalized) {
        // Keep the scoring formula intact. Only the endless credit is bounded;
        // pending/HUD/payout feedback must match the amount that can be banked.
        var _credited_gain = _gain;
        game_mode_ensure();
        if (global.game_mode == GAME_MODE_ENDLESS) {
            _credited_gain = min(_gain, max(0, ENDLESS_SCORE_MAX - global.score));
        }
        global.shot_pending_points = _credited_gain;
        if (_credited_gain >= 1000) {
            var _extra_life = min(180, round(45 * log10(_credited_gain / 1000)));
            global.score_gain_fx = {
                active: true,
                from: global.score,
                gain: _credited_gain,
                age: 0,
                life: 150 + _extra_life
            };
        }
        array_push(global.payout_fx, {
            x: _target_ball.x,
            y: _target_ball.y,
            points: _credited_gain,
            multiplier: global.risk_shot_active ? power(10, global.shot_cushion_count) : power(2, global.shot_cushion_count),
            age: 0,
            // Keep the earned-points callout readable for the same hold/fade
            // rhythm as the enlarged cushion callout.
            life: 72
        });
    }
    return true;
}

function rules_on_foul_hit(_player_ball, _foul_ball) {
    if (story_versus_active()) return story_versus_on_foul_hit(_player_ball, _foul_ball);
    if (!global.shot_active || global.game_over) return false;
    if (global.shot_penalized || global.shot_last_foul == _foul_ball) return false;

    global.shot_last_foul = _foul_ball;
    global.shot_penalized = true;
    global.shot_loss_reason = "FOUL COLLISION";
    global.shot_loss_timer = room_speed * 2;
    global.score_void_fx = {
        active: true,
        from: global.risk_shot_active ? global.score + global.shot_pending_points : global.shot_pending_points,
        x: _player_ball.x,
        y: _player_ball.y,
        age: 0,
        life: 48
    };
    global.shot_pending_points = 0;
    global.score_gain_fx.active = false;
    // A risk-shot foul clears item progress, but keeps reward progression.
    if (global.risk_shot_active) {
        global.score = 0;
        global.item_meter = 0;
    }
    global.payout_fx = [];
    global.cushion_fx = [];
    return true;
}

function rules_on_shot_ended() {
    if (!global.shot_active) return false;

    if (global.shot_scored && !global.shot_penalized) {
        game_mode_ensure();
        if (global.game_mode == GAME_MODE_ENDLESS) {
            global.score = min(ENDLESS_SCORE_MAX, global.score + global.shot_pending_points);
        } else {
            global.score += global.shot_pending_points;
        }
        global.zero_cushion_streak = (global.shot_cushion_count == 0) ? global.zero_cushion_streak + 1 : 0;
        global.chances = 3;
        if (global.score > global.best_score) {
            global.best_score = global.score;
            if (!global.new_best_shown) {
                global.new_best_shown = true;
                global.new_best_timer = room_speed * 2;
            }
            game_mode_write_best_score(global.best_score);
            global.best_save_failed = (game_mode_read_saved_best_score() != global.best_score);
        }
        rules_process_progression(min(2, global.shot_cushion_count) + (global.risk_shot_active ? 1 : 0));
    } else {
        global.zero_cushion_streak = 0;
        if (!global.shot_penalized) global.shot_loss_reason = "NO SCORE";
        global.shot_loss_timer = room_speed * 2;
        global.chances = max(0, global.chances - 1);
        // A normal foul still advances the next item by one unit.
        // Risk Shot fouls keep their existing full meter reset.
        if (global.shot_penalized && !global.risk_shot_active) rules_process_progression(1);
    }
    global.shot_pending_points = 0;
    if (global.chances <= 0) rules_finish_game();

    global.shot_active = false;
    global.balls_moving = false;
    global.risk_shot_active = false;
    global.spawn_retry_armed = true;
    return true;
}

function rules_charge_chance() {
    if (global.game_over || global.shot_penalized) return false;

    global.shot_penalized = true;
    if (global.shot_loss_reason == "") global.shot_loss_reason = "FOUL COLLISION";
    global.chances = max(0, global.chances - 1);
    if (global.chances <= 0) rules_finish_game();
    return true;
}

function rules_process_progression(_earned) {
    if (rules_items_enabled()) return rules_process_item_meter(_earned);
    return rules_process_classic_foul_pressure(_earned);
}

function rules_process_classic_foul_pressure(_earned) {
    if (rules_items_enabled()) return false;
    var _goals = [3, 5, 7];
    if (global.classic_foul_goal_index >= array_length(_goals)) return false;

    global.classic_foul_progress += _earned;
    while (global.classic_foul_goal_index < array_length(_goals)
        && global.classic_foul_progress >= _goals[global.classic_foul_goal_index]) {
        global.classic_foul_progress -= _goals[global.classic_foul_goal_index];
        global.classic_foul_goal_index += 1;
        if (global.foul_count + global.pending_foul_spawns < rules_foul_cap()) {
            global.pending_foul_spawns += 1;
        }
    }
    return true;
}

function rules_process_item_meter(_earned) {
    if (!rules_items_enabled()) return false;
    // Progress follows shot outcomes rather than the exponential point payout.
    global.item_meter += _earned;
    // Award at most one item per scoring shot; carry any surplus forward.
    if (global.item_meter >= global.item_goal) {
        global.item_meter -= global.item_goal;
        var _reward_index = global.milestone_index;
        var _reserved_choice_fouls = 0;
        for (var _q = 0; _q < array_length(global.pending_reward_foul_queue); _q++) {
            if (global.pending_reward_foul_queue[_q]) _reserved_choice_fouls += 1;
        }
        if (_reward_index < 3) {
            array_push(global.inventory, rules_milestone_item(_reward_index));
            global.milestone_index += 1;
        } else {
            array_push(global.pending_reward_queue, -1);
            array_push(global.pending_reward_foul_queue, (global.foul_count + global.pending_foul_spawns + _reserved_choice_fouls < rules_foul_cap()));
            global.pending_reward_choice = true;
            global.milestone_index += 1;
        }
        global.item_goal = (_reward_index < 2) ? [5, 7][_reward_index] : 8;
        if (_reward_index < 3 && global.foul_count + global.pending_foul_spawns < rules_foul_cap()) {
            global.pending_foul_spawns += 1;
        }
    }
}

function rules_finish_game() {
    global.game_over = true;
    global.game_over_delay = global.score_void_fx.active
        ? max(0, global.score_void_fx.life - global.score_void_fx.age) : 0;
    global.shot_active = false;
    global.balls_moving = false;
    global.risk_shot_active = false;
    global.best_score = max(global.best_score, global.score);
    game_mode_write_best_score(global.best_score);
    global.best_save_failed = (game_mode_read_saved_best_score() != global.best_score);
}

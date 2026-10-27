/// Story-mode versus rules: dual score/chance, alternating turns (verification scene).

#macro STORY_TURN_PLAYER 0
#macro STORY_TURN_AI 1
#macro STORY_MAX_TURNS 50
#macro STORY_SCORE_MAX 999999999
#macro STORY_AI_SOFT_LEAD_END 1500
#macro STORY_TURN_BANNER_SECONDS 0.5
#macro STORY_AI_TURN_DELAY_SECONDS 0.5

function story_versus_active() {
    return variable_global_exists("story_versus_active") && global.story_versus_active;
}

function story_versus_is_fifty_round_match() {
    return variable_global_exists("story_intro_match") && global.story_intro_match;
}

function story_versus_roll_break_breaker() {
    return STORY_TURN_AI;
}

function story_versus_break_foul_rules_suppressed() {
    return story_versus_is_fifty_round_match()
        && variable_global_exists("story_shot_is_break") && global.story_shot_is_break;
}

function story_versus_show_break_assign_dialogue() {
    if (!story_versus_is_fifty_round_match()) return false;
    if (!variable_global_exists("story_break_assign_dialogue_pending")
        || !global.story_break_assign_dialogue_pending) return false;
    global.story_break_assign_dialogue_pending = false;
    global.story_dialogue_id = "BREAK-ASSIGN";
    var _player_breaks = variable_global_exists("story_break_breaker")
        && global.story_break_breaker == STORY_TURN_PLAYER;
    global.story_dialogue_text = _player_breaks
        ? "손님이 브레이크를 치습니다."
        : "바텐더가 브레이크를 치습니다.";
    global.story_dialogue_timer = room_speed * 2;
    return true;
}

function story_versus_opposite_turn(_turn) {
    return (_turn == STORY_TURN_PLAYER) ? STORY_TURN_AI : STORY_TURN_PLAYER;
}

function story_versus_max_turns() {
    if (story_versus_is_fifty_round_match()
        && variable_global_exists("story_test_max_turns")
        && global.story_test_max_turns > 0) {
        return clamp(floor(global.story_test_max_turns), 1, STORY_MAX_TURNS);
    }
    return STORY_MAX_TURNS;
}

function story_score_clamp_integer(_value, _min, _max) {
    return clamp(floor(_value), _min, _max);
}

function story_score_add(_current, _points) {
    var _cur = story_score_clamp_integer(_current, 0, STORY_SCORE_MAX);
    var _pts = story_score_clamp_integer(_points, 0, STORY_SCORE_MAX);
    if (_pts >= STORY_SCORE_MAX - _cur) return STORY_SCORE_MAX;
    return _cur + _pts;
}

function story_risk_points_for_cushions(_cushions) {
    var _c = max(0, floor(_cushions));
    if (_c >= 7) return STORY_SCORE_MAX;
    return 100 * power(10, _c);
}

function story_normal_points_for_cushions(_cushions) {
    var _c = max(0, floor(_cushions));
    if (_c <= 0) return 100;
    var _remaining = STORY_SCORE_MAX;
    var _points = 100;
    for (var _i = 0; _i < _c; _i++) {
        if (_points >= _remaining) return STORY_SCORE_MAX;
        if (_points > _remaining / 2) return STORY_SCORE_MAX;
        _points *= 2;
    }
    return min(_points, STORY_SCORE_MAX);
}

function story_versus_current_round_number() {
    if (!story_versus_is_fifty_round_match()) return 1;
    if (global.story_break_pending || (variable_global_exists("story_shot_is_break") && global.story_shot_is_break))
        return 0;
    if (variable_global_exists("story_break_followup_ai_pending") && global.story_break_followup_ai_pending)
        return 0;
    return min(global.story_completed_pairs + 1, story_versus_max_turns());
}

function story_versus_init() {
    global.story_versus_active = true;
    if (story_versus_is_fifty_round_match()) {
        global.story_break_breaker = story_versus_roll_break_breaker();
        global.story_turn = global.story_break_breaker;
        global.story_break_pending = true;
        global.story_break_assign_dialogue_pending = true;
    } else {
        global.story_break_breaker = STORY_TURN_AI;
        global.story_turn = STORY_TURN_PLAYER;
        global.story_break_pending = false;
        global.story_break_assign_dialogue_pending = false;
    }
    global.story_shot_is_break = false;
    global.story_break_followup_ai_pending = false;
    global.story_turn_banner_pending = story_versus_is_fifty_round_match();
    global.story_turn_banner_timer = 0;
    global.story_player_score = 0;
    global.story_ai_score = 0;
    global.story_stage_index = 0;
    global.story_player_stage_points = 0;
    global.story_ai_stage_points = 0;
    global.story_stage_clear_pending = false;
    global.story_completed_pairs = 0;
    global.story_turn_milestone_shown_25 = false;
    global.story_turn_milestone_shown_40 = false;
    global.story_turn_milestone_shown_50 = false;
    global.story_gentle_dialogue_count = 0;
    global.story_ai_shot_was_gentle = false;
    global.story_result_dialogue_id = "";
    global.story_result_player_score = 0;
    global.story_result_ai_score = 0;
    global.story_result_score_diff = 0;
    global.story_result_completed_pairs = 0;
    if (!story_versus_is_fifty_round_match() && file_exists("cushion_foul_void_save.ini")) {
        ini_open("cushion_foul_void_save.ini");
        global.story_stage_index = clamp(ini_read_real("story", "story_stage_index", 0), 0, 15);
        global.story_player_score = max(0, ini_read_real("story", "story_checkpoint_player_score", 0));
        global.story_ai_score = max(0, ini_read_real("story", "story_checkpoint_ai_score", 0));
        ini_close();
    }
    global.story_player_chances = 3;
    global.story_ai_chances = 3;
    global.story_match_over = false;
    global.game_over_delay = 0;
    global.story_winner = -1;
    global.story_striker_ball = noone;
    global.story_last_ai_cushions = -1;
    global.story_last_ai_actual_cushions = -1;
    global.story_last_ai_actual_points = 0;
    global.story_last_ai_foul = false;
    global.story_last_ai_pass = false;
    global.risk_shot_armed = false;
    global.risk_shot_active = false;
    global.story_turn_skip_message = "";
    global.story_turn_skip_timer = 0;
    global.story_reaction_id = "";
    global.story_reaction_text = "";
    global.story_reaction_timer = 0;
    global.story_reaction_queue = [];
    global.story_item_message = "";
    global.story_item_message_timer = 0;
    global.story_rule_dialogue_index = 0;
    global.story_dialogue_id = story_versus_is_fifty_round_match() ? "RULE-01" : "";
    global.story_dialogue_text = story_versus_is_fifty_round_match()
        ? story_versus_fifty_round_rule_dialogue(0) : story_versus_stage_start_dialogue();
    global.story_dialogue_timer = story_versus_is_fifty_round_match() ? room_speed * 4 : room_speed * 5;
    if (!variable_global_exists("story_player_miss_reactions")) global.story_player_miss_reactions = 0;
    if (!variable_global_exists("story_player_high_reactions")) global.story_player_high_reactions = 0;
    if (!variable_global_exists("story_bartender_high_reactions")) global.story_bartender_high_reactions = 0;
    if (!variable_global_exists("story_close_reactions")) global.story_close_reactions = 0;
    if (!variable_global_exists("story_player_foul_reactions")) global.story_player_foul_reactions = 0;
    if (!variable_global_exists("story_bartender_foul_reactions")) global.story_bartender_foul_reactions = 0;

    global.game_over = false;
    global.place_mode = false;
    global.balls_moving = false;
    global.shot_active = false;
    global.shot_cushion_count = 0;
    global.shot_scored = false;
    global.shot_penalized = false;
    global.shot_pending_points = 0;
    global.score_gain_fx = { active: false, from: 0, gain: 0, age: 0, life: 150 };
    global.score_void_fx = { active: false, from: 0, x: 0, y: 0, age: 0, life: 48 };
    global.cushion_fx = [];
    global.payout_fx = [];
    global.foul_count = 2;
    global.pending_foul_spawns = 0;
}

function story_versus_stage_target(_stage = global.story_stage_index) {
    return [300, 500, 700, 900, 800, 1000, 1100, 1400, 1400, 2000, 1800, 2500, 2000, 2200, 3000, 3500][clamp(_stage, 0, 15)];
}

function story_versus_stage_name(_stage = global.story_stage_index) {
    return ["첫 득점", "벽의 값", "붉은 공", "첫 시험", "적은 회복", "두 번의 벽", "선택의 대가", "여유 없는 테이블", "길 만들기", "위험의 값", "지울 것인가", "거래의 끝", "숙련", "누적의 무게", "마지막 유혹", "최종 테이블"][clamp(_stage, 0, 15)];
}

function story_versus_fifty_round_rule_dialogue(_index) {
    switch (_index) {
        case 0: return "50합 한 판이야. 브레이크는 0합으로 친다.";
        case 1: return "매 합마다 손님 먼저, 그다음 내가 친다.";
        case 2: return "중간 점수로 끝나지 않아. 50합 뒤 총점으로 승부해.";
    }
    return "";
}

function story_versus_advance_rule_dialogue() {
    if (story_versus_is_fifty_round_match() && global.story_rule_dialogue_index >= 2
        && global.story_dialogue_timer <= 0 && global.story_reaction_timer <= 0
        && global.story_match_over == false) {
        story_versus_show_break_assign_dialogue();
    }
    if (!story_versus_is_fifty_round_match() || global.story_rule_dialogue_index >= 2
        || global.story_dialogue_timer > 0 || global.story_match_over) return false;
    global.story_rule_dialogue_index += 1;
    global.story_dialogue_id = "RULE-0" + string(global.story_rule_dialogue_index + 1);
    global.story_dialogue_text = story_versus_fifty_round_rule_dialogue(global.story_rule_dialogue_index);
    global.story_dialogue_timer = room_speed * 4;
    return true;
}

function story_versus_fifty_round_help_dialogue() {
    return "목표 공을 맞히면 점수가 쌓여. 상점 아이템은 손님 차례에만 살 수 있어. 위험 샷 파울이면 누적 점수가 0이 될 수 있어.";
}

function story_versus_fifty_round_turn_dialogue(_round) {
    switch (_round) {
        case 25:
            return { id: "TURN-25", text: "절반 지났어요. 이제부터는 점수 차가 술값보다 크게 느껴질 거예요." };
        case 40:
            return { id: "TURN-40", text: "40합이에요. 남은 합마다 한 번의 실수가 바로 승패로 갈 수 있어요." };
        case 50:
            return { id: "TURN-50", text: "마지막 합이에요. 이 차례 끝나면 점수판으로 승부가 납니다." };
    }
    return { id: "", text: "" };
}

function story_versus_fifty_round_result_dialogue() {
    if (global.story_winner == STORY_TURN_PLAYER) {
        return { id: "RESULT-WIN", text: "졌다. 오늘 술값은 전액 깎아줄게. 다음엔 안 봐준다.",
            discount: "술값: 전액 할인" };
    }
    if (global.story_winner == STORY_TURN_AI) {
        return { id: "RESULT-LOSE", text: "이번 판은 내 승리야. 술값은 원래대로 받는다.",
            discount: "술값: 할인 없음" };
    }
    return { id: "RESULT-DRAW", text: "끝까지 팽팽했네. 술값은 반값으로 하자.",
        discount: "술값: 반값" };
}

function story_versus_maybe_show_turn_milestone() {
    if (!story_versus_is_fifty_round_match() || global.story_match_over) return;
    var _round = story_versus_current_round_number();
    if (_round == 25 && !global.story_turn_milestone_shown_25) {
        global.story_turn_milestone_shown_25 = true;
        var _line = story_versus_fifty_round_turn_dialogue(25);
        story_versus_queue_reaction(_line.id, _line.text, room_speed * 4);
    } else if (_round == 40 && !global.story_turn_milestone_shown_40) {
        global.story_turn_milestone_shown_40 = true;
        var _line40 = story_versus_fifty_round_turn_dialogue(40);
        story_versus_queue_reaction(_line40.id, _line40.text, room_speed * 4);
    } else if (_round == 50 && !global.story_turn_milestone_shown_50) {
        global.story_turn_milestone_shown_50 = true;
        var _line50 = story_versus_fifty_round_turn_dialogue(50);
        story_versus_queue_reaction(_line50.id, _line50.text, room_speed * 5);
    }
}

function story_versus_show_gentle_dialogue() {
    if (!story_versus_is_fifty_round_match() || global.story_gentle_dialogue_count >= 2) return;
    global.story_gentle_dialogue_count += 1;
    story_versus_queue_reaction("GENTLE", "이번엔 살짝 봐줄게요. 너무 긴장하지 마요.", room_speed * 3);
}

function story_versus_stage_start_dialogue() {
    switch (global.story_stage_index) {
        case 0: return "첫 판이야. 나보다 먼저 300점 내면 술값 깎아줄게. 목표 공 맞혀 봐.";
        case 1: return "이제 벽 한 번 거친 점수만 쳐줘. 내 차례 오기 전에 길 찾아봐.";
        case 2: return "붉은 공 닿으면 점수 취소에 200점도 날아가. 나 따라잡겠다고 무리하진 마.";
        case 3: return "벽 한 번에 파울 세금까지. 이번 판도 나보다 앞설 수 있겠어?";
        case 4: return "이제 봐주는 거 줄인다. 득점해도 기회는 한 번만 돌아와. 내가 앞서기 전에 정해.";
        case 5: return "벽 두 번 거쳐야 점수야. 나도 같은 조건이니까 핑계 없기다?";
        case 6: return "파울은 200점 손해, 회복은 한 번. 나 쫓을지 기회 지킬지 골라.";
        case 7: return "벽 두 번에 기회도 빠듯해. 이제 내 손도 덜 늦출 거야. 점수판 뒤집어 봐.";
        case 8: return "공이 길 막으면 옮겨도 돼. 내가 치기 전에 유리하게 깔아 봐.";
        case 9: return "이번엔 위험 샷 점수만 목표에 들어가. 나보다 큰 한 방 칠 수 있겠어?";
        case 10: return "붉은 공 지워도 돼. 근데 쿠션 두 번은 필요해. 내 차례까지 아껴 둘 거야?";
        case 11: return "위험 샷으로만 목표 채우고 기회도 아껴야 해. 이번엔 나도 진짜로 붙는다.";
        case 12: return "벽 두 번, 적은 회복. 설명은 여기까지. 이제 점수판으로 대답해.";
        case 13: return "지금까지 번 점수도 걸려 있어. 붉은 공 하나에 200점. 내 추격 버텨 봐.";
        case 14: return "큰 점수만 목표에 들어가. 위험 샷 파울이면 다 잃어. 나보다 앞설 자신 있어?";
        case 15: return "마지막 판. 벽 두 번, 적은 기회, 파울 세금. 나도 전력으로 친다. 누가 술값 낼지 정하자.";
    }
    return "이번에는 " + string(story_versus_stage_name()) + "이야. 목표는 +" + string(story_versus_stage_target()) + "점.";
}

function story_versus_stage_help_dialogue() {
    switch (global.story_stage_index) {
        case 0: return "목표 공 맞혀서 점수 쌓으면 돼. 서두르지 마.";
        case 1: return "목표 공보다 먼저 벽을 한 번 맞혀야 해.";
        case 2: return "공 이동은 200점 내고 바로 써. 득점은 없지만 길은 만들 수 있어.";
        case 3: return "쿠션 조건이랑 파울 세금이 같이 걸려 있어.";
        case 4: return "이번 판은 득점해도 기회가 다 회복되진 않아.";
        case 5: return "목표 공 전에 쿠션 두 번 필요해.";
        case 6: return "득점 경로랑 남은 기회 같이 봐.";
        case 7: return "쿠션 두 번 먼저 만들고 목표 공 노려.";
        case 8: return "공 이동에 200점 쓰면 공 자리를 바꿀 수 있어. 그걸로 점수는 안 나와.";
        case 9: return "일반 득점은 총점엔 남는데 이번 목표엔 안 들어가.";
        case 10: return "400점 내면 파울 공 하나 바로 치울 수 있어. 필요할 때 써.";
        case 11: return "위험 샷은 800점. 1쿠션 성공 1,000점, 2쿠션 성공 10,000점. 파울이면 누적 점수 0이야.";
        case 12: return "쿠션 두 번이랑 남은 기회 확인해.";
        case 13: return "파울 세금은 누적 총점에도 붙어.";
        case 14: return "위험 샷은 800점 내고 써. 파울이면 누적 점수 0이니까 붉은 공 위치 봐.";
        case 15: return "최종전. 여러 길 시험해 봐. 정답은 하나가 아니야.";
    }
    return "목표와 남은 기회를 확인해.";
}

function story_versus_stage_clear_dialogue() {
    switch (global.story_stage_index) {
        case 0: return "벌써 감 잡았네. 오늘 술값, 좀 내려간다.";
        case 1: return "벽 쓸 줄 아네. 할인 더 해줄게.";
        case 2: return "위험한 공 잘 피했네. 내 계산이 틀어지는데?";
        case 3: return "첫 계약은 네 승리. 사실 좀 봐줬어.";
        case 4: return "기회 아껴서 이겼네. 그럼 나도 자세 좀 고쳐 잡을게.";
        case 5: return "벽 두 번까지 읽다니. 우연은 아니겠네.";
        case 6: return "무리 안 할 때도 아는구나.";
        case 7: return "이쯤 되면 내가 봐준다는 말은 못 하겠네.";
        case 8: return "테이블을 바꿀 줄도 아네.";
        case 9: return "큰 점수 가져갔네. 나도 계산 다시 해야겠다.";
        case 10: return "아껴 둔 한 수가 통했네.";
        case 11: return "좋아. 이제 술값보다 승부가 더 궁금해졌어.";
        case 12: return "제일 좋은 각을 직접 찾았네.";
        case 13: return "점수 지킬 줄 아는 사람이랑 붙으니까 재밌네.";
        case 14: return "그 배짱, 맘에 들어. 아직 한 판 남았다.";
        case 15: return "졌다. 오늘 술값은 내가 낼게. 다음엔 안 봐준다.";
    }
    return "좋아. 다음 판으로 가자.";
}

function story_versus_stage_min_cushions() {
    if (story_versus_is_fifty_round_match()) return 0;
    return (global.story_stage_index == 5 || global.story_stage_index == 7
        || global.story_stage_index == 10 || global.story_stage_index == 12
        || global.story_stage_index == 15) ? 2
        : ((global.story_stage_index == 1 || global.story_stage_index == 3
            || global.story_stage_index == 8 || global.story_stage_index == 13) ? 1 : 0);
}

function story_versus_stage_foul_tax() {
    if (story_versus_is_fifty_round_match()) return 0;
    return (global.story_stage_index == 2 || global.story_stage_index == 3
        || global.story_stage_index == 6 || global.story_stage_index == 10
        || global.story_stage_index == 13 || global.story_stage_index == 14
        || global.story_stage_index == 15) ? 200 : 0;
}

function story_versus_stage_limited_recovery() {
    if (story_versus_is_fifty_round_match()) return false;
    return (global.story_stage_index == 4 || global.story_stage_index == 6
        || global.story_stage_index == 7 || global.story_stage_index == 11
        || global.story_stage_index == 12 || global.story_stage_index == 15);
}

function story_versus_stage_risk_contract() {
    if (story_versus_is_fifty_round_match()) return false;
    return (global.story_stage_index == 9 || global.story_stage_index == 11
        || global.story_stage_index == 14 || global.story_stage_index == 15);
}

function story_versus_advance_stage() {
    if (!global.story_stage_clear_pending) return false;
    global.story_stage_clear_pending = false;
    global.story_stage_index += 1;
    global.story_player_stage_points = 0;
    global.story_ai_stage_points = 0;
    global.story_turn = STORY_TURN_AI;
    global.story_break_pending = true;
    global.story_turn_banner_pending = true;
    global.story_turn_banner_timer = 0;
    global.story_player_chances = 3;
    global.story_ai_chances = 3;
    global.story_match_over = false;
    global.game_over = false;
    global.story_dialogue_text = story_versus_stage_start_dialogue();
    global.story_dialogue_timer = room_speed * 4;
    global.story_reaction_timer = 0;
    global.story_reaction_queue = [];
    story_versus_spawn_layout();
    ini_open("cushion_foul_void_save.ini");
    ini_write_real("story", "story_stage_index", global.story_stage_index);
    ini_write_real("story", "story_checkpoint_player_score", global.story_player_score);
    ini_write_real("story", "story_checkpoint_ai_score", global.story_ai_score);
    ini_close();
    return true;
}

function story_versus_current_chances() {
    return (global.story_turn == STORY_TURN_PLAYER) ? global.story_player_chances : global.story_ai_chances;
}

function story_versus_opening_dialogue_active() {
    if (!story_versus_is_fifty_round_match() || !global.story_break_pending) return false;
    if (global.story_break_assign_dialogue_pending) return true;
    if (global.story_dialogue_timer <= 0) return false;
    return string_copy(global.story_dialogue_id, 1, 5) == "RULE-"
        || global.story_dialogue_id == "BREAK-ASSIGN";
}

function story_versus_queue_reaction(_id, _text, _frames) {
    if (_id == "" || _frames <= 0) return;
    var _line = { id: _id, text: _text, frames: _frames };
    if (global.story_reaction_timer <= 0 && global.story_dialogue_timer <= 0
        && array_length(global.story_reaction_queue) == 0) {
        global.story_reaction_id = _line.id;
        global.story_reaction_text = _line.text;
        global.story_reaction_timer = _line.frames;
    } else array_push(global.story_reaction_queue, _line);
}

function story_versus_advance_reaction_display() {
    // Help and stage dialogue use the same box; keep the current reaction's
    // full reading time while either one is visible.
    if (global.story_dialogue_timer > 0) return;
    if (global.story_reaction_timer > 0) global.story_reaction_timer -= 1;
    if (global.story_reaction_timer <= 0 && array_length(global.story_reaction_queue) > 0) {
        var _next = global.story_reaction_queue[0];
        array_delete(global.story_reaction_queue, 0, 1);
        global.story_reaction_id = _next.id;
        global.story_reaction_text = _next.text;
        global.story_reaction_timer = _next.frames;
    }
}

function story_versus_input_locked() {
    return global.story_stage_clear_pending
        || story_versus_opening_dialogue_active()
        || global.story_turn_banner_pending
        || global.story_turn_banner_timer > 0;
}

function story_versus_is_human_turn() {
    if (!story_versus_active()
        || global.story_match_over
        || global.story_turn != STORY_TURN_PLAYER
        || global.shot_active
        || global.balls_moving
        || global.place_mode) return false;
    if (story_versus_input_locked()) return false;
    if (story_versus_is_fifty_round_match()) return true;
    return global.story_player_chances > 0;
}

function story_versus_is_ai_turn() {
    return story_versus_active()
        && !global.story_match_over
        && global.story_turn == STORY_TURN_AI
        && !global.shot_active
        && !global.balls_moving
        && !story_versus_input_locked();
}

function story_versus_striker_counts_cushions(_ball) {
    if (!story_versus_active()) return false;
    if (!instance_exists(global.story_striker_ball) || _ball.id != global.story_striker_ball) return false;
    return (_ball.object_index == obj_ball_player || _ball.object_index == obj_ball_ai);
}

function story_versus_points_for_cushions(_cushions) {
    if (story_versus_is_fifty_round_match()) return story_normal_points_for_cushions(_cushions);
    if (_cushions <= 0) return 100;
    return 100 * power(2, _cushions);
}

function story_versus_item_price(_item) {
    switch (_item) {
        case 1: return 200;
        case 2: return 800;
        case 3: return 400;
    }
    return -1;
}

function story_versus_set_item_message(_text) {
    global.story_item_message = _text;
    global.story_item_message_timer = room_speed * 3;
}

function story_versus_show_help() {
    if (!story_versus_active() || global.story_match_over
        || story_versus_opening_dialogue_active()) return false;
    global.story_dialogue_id = "HELP";
    global.story_dialogue_text = story_versus_is_fifty_round_match()
        ? story_versus_fifty_round_help_dialogue() : story_versus_stage_help_dialogue();
    global.story_dialogue_timer = room_speed * 4;
    return true;
}

function story_versus_purchase_item(_item) {
    if (!story_versus_is_human_turn()) return false;
    var _price = story_versus_item_price(_item);
    if (_price < 0) return false;
    if (global.story_player_score < _price) {
        switch (_item) {
            case 1: story_versus_set_item_message("공 이동은 200점이야. 지금 점수로는 살 수 없네."); break;
            case 2: story_versus_set_item_message("위험 샷은 800점이야. 지금 점수로는 살 수 없네."); break;
            case 3: story_versus_set_item_message("파울 제거는 400점이야. 지금 점수로는 살 수 없네."); break;
        }
        return false;
    }

    var _applied = false;
    switch (_item) {
        case 1:
            global.place_mode = true;
            global.place_from_item = true;
            story_versus_set_item_message("200점을 내고 공을 옮겼어. 이동 자체로 점수는 없어.");
            _applied = true;
            break;
        case 2:
            if (!global.risk_shot_armed) {
                global.risk_shot_armed = true;
                story_versus_set_item_message(story_versus_is_fifty_round_match()
                    ? "800점을 내고 위험 샷을 골랐어. 100×10^쿠션이야. 7쿠션 이상은 점수 상한."
                    : "800점을 내고 위험 샷을 골랐어. 1쿠션은 1,000점, 2쿠션은 10,000점이야.");
                _applied = true;
            }
            break;
        case 3:
            var _foul_object = asset_get_index("obj_ball_foul");
            if (_foul_object != -1 && instance_number(_foul_object) > 0) {
                var _foul = instance_find(_foul_object, instance_number(_foul_object) - 1);
                if (_foul != noone) {
                    with (_foul) instance_destroy();
                    global.foul_count = max(0, global.foul_count - 1);
                    story_versus_set_item_message("400점을 내고 파울 공 하나를 치웠어.");
                    _applied = true;
                }
            }
            break;
    }
    if (!_applied) return false;
    if (story_versus_is_fifty_round_match()) {
        global.story_player_score = story_score_clamp_integer(global.story_player_score - _price, 0, STORY_SCORE_MAX);
    } else global.story_player_score -= _price;
    audio_sfx("snd_item", 0.6);
    return true;
}

function story_versus_on_shot_started(_ball) {
    if (global.story_match_over || global.shot_active || global.place_mode) return false;
    if (story_versus_is_fifty_round_match() && story_versus_input_locked()) return false;
    if (!instance_exists(_ball)) return false;
    var _is_player = (_ball.object_index == obj_ball_player);
    var _is_ai = (_ball.object_index == obj_ball_ai);
    if (!_is_player && !_is_ai) return false;
    if (_is_player && global.story_turn != STORY_TURN_PLAYER) return false;
    if (_is_ai && global.story_turn != STORY_TURN_AI) return false;
    if (!story_versus_is_fifty_round_match() && story_versus_current_chances() <= 0) return false;

    global.story_shot_is_break = story_versus_is_fifty_round_match() && global.story_break_pending;
    global.story_striker_ball = _ball;
    global.story_last_ai_pass = false;
    global.story_ai_shot_was_gentle = false;
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

function story_versus_on_cushion_hit(_player_ball, _cushion_count) {
    if (!global.shot_active || global.story_match_over) return false;
    if (global.shot_scored || global.shot_penalized) return false;
    if (_cushion_count <= global.shot_cushion_count) return false;
    global.shot_cushion_count = max(global.shot_cushion_count, _cushion_count);
    array_push(global.cushion_fx, {
        x: _player_ball.x,
        y: _player_ball.y,
        count: _cushion_count,
        risk: global.risk_shot_active,
        age: 0,
        life: 84
    });
    return true;
}

function story_versus_on_target_hit(_player_ball, _target_ball, _cushion_count) {
    if (!global.shot_active || global.story_match_over || global.shot_scored) return false;
    global.shot_cushion_count = max(global.shot_cushion_count, _cushion_count);
    global.shot_scored = true;
    if (!global.shot_penalized) {
        if (global.risk_shot_active) {
            global.shot_pending_points = story_versus_is_fifty_round_match()
                ? story_risk_points_for_cushions(global.shot_cushion_count)
                : ((global.shot_cushion_count <= 0) ? 100 : ((global.shot_cushion_count == 1) ? 1000 : 10000));
        } else {
            global.shot_pending_points = (global.shot_cushion_count < story_versus_stage_min_cushions())
                ? 0 : story_versus_points_for_cushions(global.shot_cushion_count);
        }
        if (global.shot_pending_points > 0) {
            var _active_score = (global.story_turn == STORY_TURN_PLAYER)
                ? global.story_player_score : global.story_ai_score;
            if (global.shot_pending_points >= 1000) {
                var _extra_life = min(180, round(45 * log10(global.shot_pending_points / 1000)));
                global.score_gain_fx = {
                    active: true,
                    from: _active_score,
                    gain: global.shot_pending_points,
                    age: 0,
                    life: 150 + _extra_life
                };
            }
            array_push(global.payout_fx, {
                x: _target_ball.x,
                y: _target_ball.y,
                points: global.shot_pending_points,
                multiplier: global.risk_shot_active
                    ? ((global.shot_cushion_count <= 0) ? 1 : power(10, min(6, global.shot_cushion_count)))
                    : (story_versus_is_fifty_round_match()
                        ? global.shot_pending_points / 100 : power(2, global.shot_cushion_count)),
                age: 0,
                life: 72
            });
        }
    }
    return true;
}

function story_versus_on_foul_hit(_player_ball, _foul_ball) {
    if (!global.shot_active || global.story_match_over) return false;
    if (story_versus_break_foul_rules_suppressed()) return false;
    if (global.shot_penalized || global.shot_last_foul == _foul_ball) return false;
    global.shot_last_foul = _foul_ball;
    global.shot_penalized = true;
    global.shot_loss_reason = "FOUL COLLISION";
    global.shot_loss_timer = room_speed * 2;
    global.score_void_fx = {
        active: true,
        from: (global.story_turn == STORY_TURN_PLAYER && global.risk_shot_active)
            ? global.story_player_score + global.shot_pending_points : global.shot_pending_points,
        x: _player_ball.x,
        y: _player_ball.y,
        age: 0,
        life: 48
    };
    global.shot_pending_points = 0;
    global.score_gain_fx.active = false;
    if (global.story_turn == STORY_TURN_PLAYER && global.risk_shot_active) {
        global.story_player_score = 0;
        if (!story_versus_is_fifty_round_match()) global.story_player_stage_points = 0;
        story_versus_set_item_message("파울이야. 위험 샷의 대가로 누적 점수가 0이 됐어.");
    }
    global.payout_fx = [];
    global.cushion_fx = [];
    return true;
}

function story_versus_add_score_to_active_side(_points) {
    if (story_versus_is_fifty_round_match()) {
        if (global.story_turn == STORY_TURN_PLAYER) {
            global.story_player_score = story_score_add(global.story_player_score, _points);
        } else {
            global.story_ai_score = story_score_add(global.story_ai_score, _points);
        }
        return;
    }
    if (global.story_turn == STORY_TURN_PLAYER) global.story_player_score += _points;
    else global.story_ai_score += _points;
}

function story_versus_spend_chance_active_side() {
    if (global.story_turn == STORY_TURN_PLAYER) {
        global.story_player_chances = max(0, global.story_player_chances - 1);
    } else {
        global.story_ai_chances = max(0, global.story_ai_chances - 1);
    }
}

function story_versus_restore_chances_active_side() {
    if (global.story_turn == STORY_TURN_PLAYER) {
        global.story_player_chances = story_versus_stage_limited_recovery()
            ? min(3, global.story_player_chances + 1) : 3;
    } else {
        global.story_ai_chances = story_versus_stage_limited_recovery()
            ? min(3, global.story_ai_chances + 1) : 3;
    }
}

/// Bartender lines respond to the committed result, not the provisional hit.
function story_versus_react_to_shot(_turn, _points, _foul) {
    if (!variable_global_exists("story_intro_match") || !global.story_intro_match) return;

    var _id = "";
    var _text = "";
    if (_turn == STORY_TURN_PLAYER) {
        if (_foul) {
            if (global.story_player_foul_reactions mod 2 == 0) {
                _id = "EVT-PLAYER-FOUL-01";
                _text = "붉은 공에 닿았네요. 승부가 저한테 기울겠는데요?";
            } else {
                _id = "EVT-PLAYER-FOUL-02";
                _text = "아쉬운 실수예요. 제가 그 틈을 놓칠 것 같나요?";
            }
            global.story_player_foul_reactions += 1;
        } else if (_points <= 0) {
            if (global.story_player_miss_reactions mod 2 == 0) {
                _id = "EVT-PLAYER-MISS-01";
                _text = "빈손이네요? 제 차례엔 공이 좀 움직일 겁니다.";
            } else {
                _id = "EVT-PLAYER-MISS-02";
                _text = "그 공은 아쉽네요. 자, 이번엔 제가 보여 드리죠.";
            }
            global.story_player_miss_reactions += 1;
        } else if (_points > 1000) {
            if (global.story_player_high_reactions mod 2 == 0) {
                _id = "EVT-PLAYER-HIGH-01";
                _text = "잠깐, 그 각도를 읽었다고요? 생각보다 훨씬 잘 치시네요.";
            } else {
                _id = "EVT-PLAYER-HIGH-02";
                _text = "그 점수는 예상 밖인데요. 제가 슬슬 진지해져야겠어요.";
            }
            global.story_player_high_reactions += 1;
        } else if (global.story_ai_score > 0
            && (story_versus_is_fifty_round_match()
                || (global.story_player_score < 300 && global.story_ai_score < 300))
            && abs(global.story_player_score - global.story_ai_score) <= 200) {
            if (global.story_close_reactions mod 2 == 0) {
                _id = "EVT-CLOSE-01";
                _text = "점수 차가 200점 이내네요. 이제 한 번의 쿠션이 승부를 바꿔요.";
            } else {
                _id = "EVT-CLOSE-02";
                _text = "바로 뒤에 있군요. 좋아요, 이래야 승부답죠.";
            }
            global.story_close_reactions += 1;
        } else {
            _id = "EVT-PLAYER-SCORE-01";
            _text = "좋은 샷이에요. 각도를 잘 읽으셨네요.";
        }
    } else {
        if (_foul) {
            if (global.story_bartender_foul_reactions mod 2 == 0) {
                _id = "EVT-BARTENDER-FOUL-01";
                _text = "제 실수예요. 이번엔 당신이 웃을 차례군요.";
            } else {
                _id = "EVT-BARTENDER-FOUL-02";
                _text = "이런, 붉은 공이라니. 방심한 값을 치렀네요.";
            }
            global.story_bartender_foul_reactions += 1;
        } else if (_points > 1000) {
            if (global.story_bartender_high_reactions mod 2 == 0) {
                _id = "EVT-BARTENDER-HIGH-01";
                _text = "봤죠? 이 테이블에선 제가 조금 더 익숙합니다.";
            } else {
                _id = "EVT-BARTENDER-HIGH-02";
                _text = "벽을 몇 번이나 거쳤죠. 술값 계산이 다시 재밌어지네요.";
            }
            global.story_bartender_high_reactions += 1;
        } else if (_points > 0 && global.story_player_score > 0
            && (story_versus_is_fifty_round_match()
                || (global.story_player_score < 300 && global.story_ai_score < 300))
            && abs(global.story_player_score - global.story_ai_score) <= 200) {
            if (global.story_close_reactions mod 2 == 0) {
                _id = "EVT-CLOSE-01";
                _text = "점수 차가 200점 이내네요. 이제 한 번의 쿠션이 승부를 바꿔요.";
            } else {
                _id = "EVT-CLOSE-02";
                _text = "바로 뒤에 있군요. 좋아요, 이래야 승부답죠.";
            }
            global.story_close_reactions += 1;
        } else if (_points > 0) {
            _id = "EVT-BARTENDER-SCORE-01";
            _text = "깔끔하게 들어갔죠? 제 점수도 올라갑니다.";
        } else {
            _id = "EVT-BARTENDER-MISS-01";
            _text = "이런, 제 공도 말을 안 듣네요. 이번엔 당신 차례예요.";
        }
    }

    story_versus_queue_reaction(_id, _text, room_speed * 4);
}

function story_versus_finalize_fifty_round_match() {
    if (!story_versus_is_fifty_round_match() || global.story_match_over) return false;
    if (global.story_completed_pairs < story_versus_max_turns()) return false;
    global.story_player_score = story_score_clamp_integer(global.story_player_score, 0, STORY_SCORE_MAX);
    global.story_ai_score = story_score_clamp_integer(global.story_ai_score, 0, STORY_SCORE_MAX);
    global.story_result_player_score = global.story_player_score;
    global.story_result_ai_score = global.story_ai_score;
    global.story_result_score_diff = global.story_player_score - global.story_ai_score;
    global.story_result_completed_pairs = global.story_completed_pairs;
    if (global.story_player_score > global.story_ai_score) global.story_winner = STORY_TURN_PLAYER;
    else if (global.story_ai_score > global.story_player_score) global.story_winner = STORY_TURN_AI;
    else global.story_winner = -1;
    global.story_match_over = true;
    global.game_over = true;
    var _result = story_versus_fifty_round_result_dialogue();
    global.story_result_dialogue_id = _result.id;
    global.story_dialogue_id = _result.id;
    global.story_dialogue_text = _result.text;
    global.story_dialogue_timer = room_speed * 8;
    global.story_reaction_timer = 0;
    global.story_reaction_text = "";
    global.story_reaction_queue = [];
    ini_open("cushion_foul_void_save.ini");
    ini_write_real("story", "story_first_match_done", 1);
    ini_close();
    return true;
}

function story_versus_check_match_over() {
    if (story_versus_is_fifty_round_match()) return global.story_match_over;
    if (variable_global_exists("story_intro_match") && global.story_intro_match) {
        if (global.story_player_stage_points >= story_versus_stage_target()
            || global.story_ai_stage_points >= story_versus_stage_target()
            || global.story_player_chances <= 0) {
            if (global.story_player_stage_points >= story_versus_stage_target()
                && global.story_stage_index < 15) {
                global.story_stage_clear_pending = true;
                global.story_dialogue_text = story_versus_stage_clear_dialogue();
                global.story_dialogue_timer = room_speed * 6;
                return true;
            }
            global.story_match_over = true;
            global.story_winner = (global.story_player_stage_points >= story_versus_stage_target()) ? STORY_TURN_PLAYER : STORY_TURN_AI;
            global.game_over = true;
            if (global.story_winner == STORY_TURN_PLAYER) {
                global.story_dialogue_text = story_versus_stage_clear_dialogue();
                global.story_dialogue_timer = room_speed * 6;
            }
            ini_open("cushion_foul_void_save.ini");
            ini_write_real("story", "story_first_match_done", 1);
            ini_close();
            return true;
        }
    }
    if (global.story_player_chances <= 0 && global.story_ai_chances <= 0) {
        global.story_match_over = true;
        if (global.story_player_score > global.story_ai_score) global.story_winner = STORY_TURN_PLAYER;
        else if (global.story_ai_score > global.story_player_score) global.story_winner = STORY_TURN_AI;
        else global.story_winner = -1;
        global.game_over = true;
        return true;
    }
    return false;
}

function story_versus_advance_turn() {
    global.story_turn = (global.story_turn == STORY_TURN_PLAYER) ? STORY_TURN_AI : STORY_TURN_PLAYER;
    global.story_striker_ball = noone;
    global.story_turn_banner_pending = (variable_global_exists("story_intro_match") && global.story_intro_match);
    global.story_turn_banner_timer = 0;
}

function story_versus_on_shot_ended() {
    if (!global.shot_active) return false;

    var _shot_turn = global.story_turn;
    var _shot_points = (global.shot_scored && !global.shot_penalized) ? global.shot_pending_points : 0;
    var _shot_foul = global.shot_penalized;
    var _was_break = story_versus_is_fifty_round_match() && global.story_shot_is_break;

    if (global.story_turn == STORY_TURN_AI) {
        global.story_last_ai_actual_cushions = global.shot_cushion_count;
        global.story_last_ai_actual_points = (global.shot_scored && !global.shot_penalized) ? global.shot_pending_points : 0;
        global.story_last_ai_foul = global.shot_penalized;
    }

    if (global.shot_scored && !global.shot_penalized) {
        story_versus_add_score_to_active_side(global.shot_pending_points);
        if (!story_versus_is_fifty_round_match()) {
            if (!story_versus_stage_risk_contract() || global.risk_shot_active) {
                if (_shot_turn == STORY_TURN_PLAYER) global.story_player_stage_points += global.shot_pending_points;
                else global.story_ai_stage_points += global.shot_pending_points;
            }
            story_versus_restore_chances_active_side();
        }
    } else if (!story_versus_is_fifty_round_match()) {
        if (_shot_turn == STORY_TURN_PLAYER && _shot_foul && story_versus_stage_foul_tax() > 0) {
            global.story_player_score = max(0, global.story_player_score - story_versus_stage_foul_tax());
            global.story_player_stage_points = max(0, global.story_player_stage_points - story_versus_stage_foul_tax());
        } else if (_shot_turn == STORY_TURN_AI && _shot_foul && story_versus_stage_foul_tax() > 0) {
            global.story_ai_score = max(0, global.story_ai_score - story_versus_stage_foul_tax());
            global.story_ai_stage_points = max(0, global.story_ai_stage_points - story_versus_stage_foul_tax());
        }
        story_versus_spend_chance_active_side();
    }

    if (!global.story_match_over) {
        story_versus_react_to_shot(_shot_turn, _shot_points, _shot_foul);
        if (story_versus_is_fifty_round_match() && _shot_turn == STORY_TURN_AI
            && global.story_ai_shot_was_gentle) story_versus_show_gentle_dialogue();
    }
    global.story_ai_shot_was_gentle = false;

    global.shot_pending_points = 0;
    global.shot_active = false;
    global.balls_moving = false;
    global.risk_shot_active = false;
    global.spawn_retry_armed = true;
    global.story_shot_is_break = false;

    if (story_versus_is_fifty_round_match()) {
        global.story_striker_ball = noone;
        if (_was_break) {
            global.story_break_pending = false;
            var _breaker = variable_global_exists("story_break_breaker")
                ? global.story_break_breaker : STORY_TURN_AI;
            global.story_turn = story_versus_opposite_turn(_breaker);
            // A player break is 0合. The AI's reply also precedes pair 1,
            // whose normal order remains player then AI.
            global.story_break_followup_ai_pending = (_breaker == STORY_TURN_PLAYER);
            global.story_turn_banner_pending = true;
            global.story_turn_banner_timer = 0;
            return true;
        }
        if (_shot_turn == STORY_TURN_AI && global.story_break_followup_ai_pending) {
            global.story_break_followup_ai_pending = false;
            global.story_turn = STORY_TURN_PLAYER;
            global.story_turn_banner_pending = true;
            global.story_turn_banner_timer = 0;
            return true;
        }
        if (_shot_turn == STORY_TURN_PLAYER) {
            global.story_turn = STORY_TURN_AI;
        } else {
            global.story_completed_pairs += 1;
            if (global.story_completed_pairs >= story_versus_max_turns()) {
                story_versus_finalize_fifty_round_match();
                return true;
            }
            global.story_turn = STORY_TURN_PLAYER;
            story_versus_maybe_show_turn_milestone();
        }
        global.story_turn_banner_pending = true;
        global.story_turn_banner_timer = 0;
        return true;
    }

    story_versus_advance_turn();
    story_versus_check_match_over();
    return true;
}

function story_versus_pass_turn_no_shot(_message) {
    if (global.story_match_over || global.shot_active || global.balls_moving) return false;
    if (story_versus_is_fifty_round_match()) {
        if (global.story_turn != STORY_TURN_AI) return false;
        global.story_ai_shot_was_gentle = false;
        global.risk_shot_active = false;
        global.story_turn_skip_message = _message;
        global.story_turn_skip_timer = room_speed * 2;
        if (global.story_break_pending) {
            global.story_break_pending = false;
            global.story_shot_is_break = false;
            var _pass_breaker = variable_global_exists("story_break_breaker")
                ? global.story_break_breaker : STORY_TURN_AI;
            global.story_turn = story_versus_opposite_turn(_pass_breaker);
            global.story_turn_banner_pending = true;
            global.story_turn_banner_timer = 0;
            return true;
        }
        if (global.story_break_followup_ai_pending) {
            global.story_break_followup_ai_pending = false;
            global.story_turn = STORY_TURN_PLAYER;
            global.story_turn_banner_pending = true;
            global.story_turn_banner_timer = 0;
            return true;
        }
        global.story_completed_pairs += 1;
        if (global.story_completed_pairs >= story_versus_max_turns()) {
            story_versus_finalize_fifty_round_match();
            return true;
        }
        global.story_turn = STORY_TURN_PLAYER;
        global.story_turn_banner_pending = true;
        global.story_turn_banner_timer = 0;
        story_versus_maybe_show_turn_milestone();
        return true;
    }
    story_versus_spend_chance_active_side();
    global.story_turn_skip_message = _message;
    global.story_turn_skip_timer = room_speed * 2;
    story_versus_advance_turn();
    story_versus_check_match_over();
    return true;
}

function story_versus_skip_turn_if_no_chances() {
    if (global.story_match_over || global.shot_active || global.balls_moving) return false;
    var _ch = story_versus_current_chances();
    if (_ch > 0) return false;
    global.story_turn_skip_message = "NO CHANCES";
    global.story_turn_skip_timer = room_speed * 1;
    story_versus_advance_turn();
    story_versus_check_match_over();
    return true;
}

function story_versus_spawn_ball_at(_asset_name, _x, _y) {
    var _object = asset_get_index(_asset_name);
    if (_object == -1) return noone;
    return instance_create_layer(_x, _y, "Instances", _object);
}

function story_versus_spawn_layout() {
    application_destroy_all_balls();
    story_versus_spawn_ball_at("obj_ball_player", 380, 350);
    story_versus_spawn_ball_at("obj_ball_ai", 900, 350);
    if (variable_global_exists("story_intro_match") && global.story_intro_match) {
        // Three tangent balls form the rack for the bartender's opening shot.
        story_versus_spawn_ball_at("obj_ball_target", 640, 350);
        story_versus_spawn_ball_at("obj_ball_foul", 608, 350);
        story_versus_spawn_ball_at("obj_ball_foul", 624, 322);
    } else {
        story_versus_spawn_ball_at("obj_ball_target", 640, 260);
        story_versus_spawn_ball_at("obj_ball_foul", 520, 480);
        story_versus_spawn_ball_at("obj_ball_foul", 760, 480);
    }
}

function story_versus_draw_hud() {
    var _gui_w = display_get_gui_width();
    if (variable_global_exists("story_intro_match") && global.story_intro_match) {
        var _power_left = 24;
        var _power_right = clamp(_gui_w * 0.27, 250, 330);
        var _panel_left = _power_right + 16;
        var _panel_right = _gui_w - 18;
        var _column_w = (_panel_right - _panel_left - 28) / 3;
        var _column_1 = _panel_left + 14;
        var _column_2 = _column_1 + _column_w;
        var _column_3 = _column_2 + _column_w;
        var _power = 0;
        if (instance_exists(obj_cue) && variable_instance_exists(obj_cue, "power_normalized"))
            _power = clamp(obj_cue.power_normalized, 0, 1);

        lang_font_init();
        draw_set_alpha(1);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(make_color_rgb(10, 23, 27));
        draw_roundrect(_power_left, 8, _power_right, 76, false);
        ui_text_fit_px(_power_left + 14, 12, tr("POWER", "파워"), _power_right - _power_left - 28, 2, make_color_rgb(213, 168, 85));
        draw_set_color(make_color_rgb(42, 60, 63));
        draw_roundrect(_power_left + 14, 50, _power_right - 14, 66, false);
        draw_set_color(make_color_rgb(237, 187, 76));
        draw_roundrect(_power_left + 14, 50, _power_left + 14 + (_power_right - _power_left - 28) * _power, 66, false);

        draw_set_color(make_color_rgb(10, 23, 27));
        draw_roundrect(_panel_left, 8, _panel_right, 76, false);
        var _round_label = global.story_break_pending ? "브레이크"
            : (string(story_versus_current_round_number()) + "/" + string(story_versus_max_turns()));
        var _turn_label = (global.story_turn == STORY_TURN_PLAYER) ? "손님 차례" : "바텐더 차례";
        var _diff = global.story_player_score - global.story_ai_score;
        var _diff_label = (_diff == 0) ? "동점" : ("차이 " + string(abs(_diff)) + ((_diff > 0) ? "↑" : "↓"));
        draw_set_halign(fa_left);
        ui_text_fit_px(_column_1, 11, "합 " + _round_label, _column_w - 12, 2, c_white);
        ui_text_fit_px(_column_2, 11, "손님 " + string(global.story_player_score), _column_w - 12, 2, c_white);
        ui_text_fit_px(_column_3, 11, "바텐더 " + string(global.story_ai_score), _column_w - 12, 2, c_white);
        ui_text_fit_px(_column_1, 43, _diff_label, _column_w - 12, 2, make_color_rgb(213, 168, 85));
        ui_text_fit_px(_column_2, 43, _turn_label, _column_w - 12, 2, make_color_rgb(213, 168, 85));
        ui_text_fit_px(_column_3, 43, "H 도움말", _column_w - 12, 2, c_white);
        if (global.story_turn_banner_timer > 0 && !global.story_match_over) {
            var _banner_alpha = min(1, global.story_turn_banner_timer / 6,
                (round(room_speed * STORY_TURN_BANNER_SECONDS) - global.story_turn_banner_timer) / 6);
            var _banner_color = (global.story_turn == STORY_TURN_PLAYER)
                ? make_color_rgb(255, 214, 110) : make_color_rgb(98, 211, 231);
            var _banner_round = story_versus_current_round_number();
            var _banner_text = (_banner_round <= 0)
                ? ((global.story_break_pending ? "브레이크" : "0합") + " · " + _turn_label)
                : (string(_banner_round) + "합 · " + _turn_label
                    + ((_banner_round == story_versus_max_turns()) ? " (마지막)" : ""));
            draw_set_alpha(0.9 * _banner_alpha);
            draw_set_color(make_color_rgb(10, 23, 27));
            draw_roundrect(_gui_w * 0.5 - 220, 166, _gui_w * 0.5 + 220, 230, false);
            draw_set_alpha(_banner_alpha);
            draw_set_color(_banner_color);
            draw_roundrect(_gui_w * 0.5 - 220, 166, _gui_w * 0.5 + 220, 230, true);
            draw_set_halign(fa_center);
            pixel_draw_text_transformed(_gui_w * 0.5, 184, _banner_text, 2, 2, 0, true);
            draw_set_alpha(1);
        }
        if (global.story_match_over) {
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(make_color_rgb(12, 34, 30));
            draw_set_alpha(0.92);
            draw_rectangle(120, 580, 1160, 710, false);
            draw_set_alpha(1);
            draw_set_color(make_color_rgb(239, 225, 193));
            draw_sprite_ext(spr_assistant_dialogue, 0, 1063, 704, 0.10, 0.10, 0, c_white, 1);
            var _result_line = story_versus_fifty_round_result_dialogue();
            var _score_line = "손님 " + string(global.story_player_score)
                + "  ·  바텐더 " + string(global.story_ai_score)
                + "  ·  " + string(global.story_completed_pairs) + "합";
            pixel_draw_text_transformed(640, 598, _score_line, 1, 1, 0, false);
            if (global.story_dialogue_timer > 0)
                pixel_draw_text_transformed(640, 628, "바텐더: " + global.story_dialogue_text, 1, 1, 0, false);
            else if (global.story_reaction_timer > 0)
                pixel_draw_text_transformed(640, 628, "바텐더: " + global.story_reaction_text, 1, 1, 0, false);
            else
                pixel_draw_text_transformed(640, 628, "바텐더: " + _result_line.text, 1, 1, 0, false);
            pixel_draw_text_transformed(640, 658, _result_line.discount, 1, 1, 0, false);
            pixel_draw_text_transformed(640, 688, "ENTER 또는 클릭: 메뉴로", 1, 1, 0, false);
        } else {
            {
                var _shop_active = story_versus_is_human_turn();
                var _shop_y = ui_inventory_y + 22;
                var _shop_gap = ui_slot_gap;
                var _shop_size = ui_slot_size;
                var _shop_start_x = (_gui_w - (3 * _shop_size + 2 * _shop_gap)) * 0.5;
                var _shop_icons = [spr_item_move, spr_item_risk_shot, spr_item_remove];
                var _shop_prices = [200, 800, 400];
                var _shop_names = ["이동", "위험", "제거"];
                var _shop_mx = device_mouse_x_to_gui(0);
                var _shop_my = device_mouse_y_to_gui(0);
                draw_set_halign(fa_center);
                draw_set_color(make_color_rgb(205, 165, 80));
                pixel_draw_text_transformed(_gui_w * 0.5, _shop_y - 36, "상점", 1, 1, 0, false);
                for (var _shop_i = 0; _shop_i < 3; _shop_i++) {
                    var _shop_x = _shop_start_x + _shop_i * (_shop_size + _shop_gap);
                    var _can_buy = _shop_active && global.story_player_score >= _shop_prices[_shop_i];
                    var _price_hover = _can_buy && ui_button_hit(_shop_mx, _shop_my, _shop_x, _shop_y, _shop_size, _shop_size);
                    var _ui_owner = instance_find(obj_ui, 0);
                    var _shop_state = UI_BUTTON_DISABLED;
                    if (_can_buy) {
                        _shop_state = ui_button_state(_price_hover);
                        if (instance_exists(_ui_owner)
                            && ui_button_is_pressed(_ui_owner, "shop" + string(_shop_i + 1)))
                            _shop_state = UI_BUTTON_PRESSED;
                    }
                    ui_button_draw("", _shop_x, _shop_y, _shop_size, _shop_size, true, _shop_state);
                    draw_set_alpha(_can_buy ? 1 : 0.45);
                    draw_sprite_ext(_shop_icons[_shop_i], 0, _shop_x + _shop_size * 0.5, _shop_y + 29,
                        0.65, 0.65, 0, c_white, _can_buy ? 1 : 0.45);
                    draw_set_alpha(1);
                    draw_set_color(_can_buy ? make_color_rgb(255, 222, 116) : make_color_rgb(148, 148, 148));
                    pixel_draw_text_transformed(_shop_x + _shop_size * 0.5, _shop_y - 14,
                        string(_shop_i + 1) + " " + _shop_names[_shop_i], 1, 1, 0, false);
                    pixel_draw_menu_text(_shop_x + _shop_size * 0.5, _shop_y + 52,
                        string(_shop_prices[_shop_i]), 1, true);
                }
                draw_set_color(make_color_rgb(205, 165, 80));
                draw_set_halign(fa_left);
                pixel_draw_text_transformed(16, 684, "H: 도움말  ·  아이템은 가진 점수에서 바로 차감", 1, 1, 0, false);
            }
            if (global.story_item_message_timer > 0 && global.story_item_message != "") {
                draw_set_halign(fa_left);
                draw_set_color(make_color_rgb(255, 222, 116));
                pixel_draw_text_transformed(24, 244, global.story_item_message, 1, 1, 0, false);
            }
            if (global.story_reaction_timer > 0 || global.story_dialogue_timer > 0) {
                draw_set_color(make_color_rgb(13, 37, 32));
                draw_set_alpha(0.94);
                draw_rectangle(170, 84, 1110, 132, false);
                draw_set_alpha(1);
                draw_set_color(make_color_rgb(205, 165, 80));
                draw_rectangle(170, 84, 1110, 132, true);
                draw_sprite_ext(spr_assistant_dialogue, 0, 1080, 130, 0.05, 0.05, 0, c_white, 1);
                draw_set_color(make_color_rgb(239, 225, 193));
                var _dialogue_line = (global.story_dialogue_timer > 0)
                    ? global.story_dialogue_text : global.story_reaction_text;
                draw_set_halign(fa_left);
                pixel_draw_text_transformed(190, 102, "바텐더: " + _dialogue_line, 1, 1, 0, false);
            }
            if (global.story_turn_skip_timer > 0)
                pixel_draw_text_transformed(24, 144, global.story_turn_skip_message, 1, 1, 0, false);
        }
        return;
    }
    lang_font_init();
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    pixel_draw_text(24, 16, "STORY AI VERIFY");
    pixel_draw_text(24, 44, "YOU  " + string(global.story_player_score) + "  CH " + string(global.story_player_chances));
    pixel_draw_text(24, 72, "AI   " + string(global.story_ai_score) + "  CH " + string(global.story_ai_chances));
    var _turn = (global.story_turn == STORY_TURN_PLAYER) ? "PLAYER TURN" : "AI TURN";
    pixel_draw_text(24, 100, _turn);
    if (global.story_last_ai_cushions >= 2) {
        pixel_draw_text(24, 128, "AI PRED " + string(global.story_last_ai_cushions)
            + " / ACTUAL " + string(global.story_last_ai_actual_cushions));
        var _ai_result = global.story_last_ai_foul ? "FOUL"
            : ((global.story_last_ai_actual_points > 0) ? "+" + string(global.story_last_ai_actual_points) : "MISS");
        pixel_draw_text(24, 156, "AI RESULT " + _ai_result);
    }
    if (global.story_turn_skip_timer > 0) {
        pixel_draw_text(24, 184, global.story_turn_skip_message);
    }
    if (global.story_match_over) {
        var _msg = "MATCH OVER";
        if (global.story_winner == STORY_TURN_PLAYER) _msg = "YOU WIN";
        else if (global.story_winner == STORY_TURN_AI) _msg = "AI WINS";
        else _msg = "DRAW";
        draw_set_halign(fa_center);
        pixel_draw_text(_gui_w * 0.5, 320, _msg);
    }
}

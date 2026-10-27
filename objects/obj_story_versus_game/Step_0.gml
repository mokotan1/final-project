if (variable_global_exists("game_settings_open") && global.game_settings_open) exit;

if (global.story_match_over) {
    if (variable_global_exists("story_intro_match") && global.story_intro_match
        && (keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left))) {
        application_go_to_main_menu();
    }
    exit;
}

if (global.story_stage_clear_pending && !story_versus_is_fifty_round_match()) {
    if (keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left)) {
        story_versus_advance_stage();
    }
    exit;
}

if (global.story_turn_skip_timer > 0) global.story_turn_skip_timer -= 1;
if (global.story_item_message_timer > 0) global.story_item_message_timer -= 1;
if (global.story_dialogue_timer > 0) global.story_dialogue_timer -= 1;
story_versus_advance_reaction_display();
story_versus_advance_rule_dialogue();

if (!story_versus_is_fifty_round_match()) {
    repeat (4) {
        if (!story_versus_skip_turn_if_no_chances()) break;
    }
}

if (global.shot_active && physics_all_balls_stopped()) {
    story_versus_on_shot_ended();
}

if (global.story_turn_banner_pending && !global.story_match_over
    && (!global.story_stage_clear_pending || story_versus_is_fifty_round_match())
    && !global.shot_active && !global.balls_moving
    && !story_versus_opening_dialogue_active()) {
    global.story_turn_banner_pending = false;
    global.story_turn_banner_timer = round(room_speed * STORY_TURN_BANNER_SECONDS);
}
if (global.story_turn_banner_timer > 0) global.story_turn_banner_timer -= 1;

if (story_versus_is_ai_turn()) {
    if (!story_versus_is_fifty_round_match() && global.story_ai_chances <= 0) {
        story_versus_skip_turn_if_no_chances();
        ai_turn_delay = 0;
    } else if (ai_turn_delay <= 0) {
        ai_turn_delay = round(room_speed * STORY_AI_TURN_DELAY_SECONDS);
    } else {
        ai_turn_delay -= 1;
        if (ai_turn_delay <= 0) story_ai_execute_turn();
    }
}

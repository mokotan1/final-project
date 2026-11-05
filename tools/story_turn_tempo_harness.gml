// Temporary Runner harness for the story dialogue/turn timing contract.
var _failures = "";

global.story_rule_dialogue_index = 0;
global.story_break_pending = true;
global.story_break_assign_dialogue_pending = true;
global.story_turn = STORY_TURN_AI;
global.story_dialogue_id = "RULE-01";
global.story_dialogue_timer = room_speed;
global.story_turn_banner_pending = false;
global.story_turn_banner_timer = 0;
if (story_versus_is_ai_turn()) _failures += "opening-rule-unlocked ";
if (!story_versus_skip_dialogue()) _failures += "opening-rule-not-skippable ";
story_versus_advance_rule_dialogue();
if (global.story_dialogue_id != "RULE-02" || global.story_dialogue_timer <= 0)
    _failures += "opening-next-rule ";
if (!story_versus_skip_dialogue()) _failures += "rule-2-not-skippable ";
story_versus_advance_rule_dialogue();
if (global.story_dialogue_id != "RULE-03") _failures += "opening-third-rule ";
if (!story_versus_skip_dialogue()) _failures += "rule-3-not-skippable ";
story_versus_advance_rule_dialogue();
if (global.story_dialogue_id != "BREAK-ASSIGN" || !story_versus_opening_dialogue_active())
    _failures += "opening-break-assign ";
if (!story_versus_skip_dialogue() || story_versus_opening_dialogue_active())
    _failures += "opening-break-skip ";

global.story_rule_dialogue_index = 2;
global.story_break_assign_dialogue_pending = false;
global.story_dialogue_id = "BREAK-ASSIGN";
global.story_dialogue_timer = room_speed;
if (story_versus_is_ai_turn()) _failures += "breaker-line-unlocked ";

global.story_break_pending = false;
global.story_dialogue_id = "HELP";
global.story_dialogue_timer = room_speed * 4;
global.story_reaction_timer = room_speed * 4;
global.story_turn = STORY_TURN_PLAYER;
if (!story_versus_is_human_turn()) _failures += "human-reaction-locked ";
global.story_turn = STORY_TURN_AI;
if (!story_versus_is_ai_turn()) _failures += "ai-reaction-locked ";

global.story_stage_clear_pending = true;
if (story_versus_is_human_turn() || story_versus_is_ai_turn()) _failures += "stage-clear-unlocked ";
global.story_stage_clear_pending = false;

global.story_turn = STORY_TURN_PLAYER;
global.story_turn_banner_pending = true;
global.story_turn_banner_timer = 0;
event_perform(ev_step, 0);
if (global.story_turn_banner_pending || global.story_turn_banner_timer < round(room_speed * 0.5) - 2
    || global.story_turn_banner_timer > round(room_speed * 0.5)) _failures += "banner-delay ";
global.story_turn_banner_timer = 0;
if (!story_versus_is_human_turn()) _failures += "human-after-banner-locked ";

global.story_turn = STORY_TURN_AI;
ai_turn_delay = 0;
event_perform(ev_step, 0);
if (ai_turn_delay < round(room_speed * 0.5) - 1
    || ai_turn_delay > round(room_speed * 0.5)) _failures += "ai-delay ";

global.story_turn = STORY_TURN_PLAYER;
global.story_reaction_timer = 0;
global.story_dialogue_timer = 0;
global.story_dialogue_id = "";
if (!story_versus_show_help() || !story_versus_is_human_turn()) _failures += "help-locked ";

global.story_dialogue_timer = 0;
global.story_reaction_timer = 0;
global.story_reaction_queue = [];
story_versus_queue_reaction("FIRST", "First line", room_speed * 4);
story_versus_queue_reaction("SECOND", "Second line", room_speed * 4);
if (global.story_reaction_id != "FIRST" || array_length(global.story_reaction_queue) != 1)
    _failures += "reaction-overwrite ";
var _held_frames = global.story_reaction_timer;
story_versus_show_help();
story_versus_advance_reaction_display();
if (global.story_reaction_timer != _held_frames) _failures += "help-hides-reaction ";
global.story_dialogue_timer = 0;
global.story_reaction_timer = 1;
story_versus_advance_reaction_display();
if (global.story_reaction_id != "SECOND" || global.story_reaction_timer != clamp(room_speed + string_length("Second line") * 2, room_speed * 2, room_speed * 4)
    || array_length(global.story_reaction_queue) != 0) _failures += "reaction-queue-drain ";

story_versus_init();
story_versus_spawn_layout();
global.story_rule_dialogue_index = 2;
global.story_break_assign_dialogue_pending = false;
global.story_dialogue_id = "HELP";
global.story_dialogue_timer = room_speed * 4;
global.story_reaction_timer = room_speed * 4;
global.story_turn_banner_pending = false;
global.story_turn_banner_timer = 0;
if (!story_ai_execute_turn() || !global.shot_active) _failures += "ai-shot-during-dialogue ";

var _result = (_failures == "") ? "PASS opening,breaker,overlay,stage-clear,banner-0.5s,ai-0.5s,help,reaction-queue,ai-shot"
    : ("FAIL " + _failures);
var _file = file_text_open_write("story_turn_tempo_test.txt");
file_text_write_string(_file, _result);
file_text_close(_file);
show_debug_message("STORY_TURN_TEMPO_TEST " + _result);
game_end();

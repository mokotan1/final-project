// Temporary build-time visual fixture; not registered as a GameMaker resource.
global.story_break_pending = false;
global.story_shot_is_break = false;
global.story_completed_pairs = STORY_MAX_TURNS;
global.story_player_score = STORY_SCORE_MAX;
global.story_ai_score = STORY_SCORE_MAX;
global.story_rule_dialogue_index = 2;
global.story_dialogue_timer = 0;
global.story_reaction_timer = 0;
story_versus_finalize_fifty_round_match();

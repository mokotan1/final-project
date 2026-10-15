/// Run mode: endless (items + 6 fouls) vs classic (no items, 4 fouls).

#macro GAME_MODE_ENDLESS 0
#macro GAME_MODE_CLASSIC 1

function game_mode_ensure() {
    if (!variable_global_exists("game_mode")) global.game_mode = GAME_MODE_ENDLESS;
}

function rules_foul_cap() {
    game_mode_ensure();
    return (global.game_mode == GAME_MODE_CLASSIC) ? 4 : 6;
}

function rules_items_enabled() {
    game_mode_ensure();
    return global.game_mode != GAME_MODE_CLASSIC;
}

function game_mode_best_ini_key() {
    game_mode_ensure();
    return (global.game_mode == GAME_MODE_CLASSIC) ? "best_score_classic" : "best_score_endless";
}

function game_mode_display_name(_mode = undefined) {
    if (is_undefined(_mode)) {
        game_mode_ensure();
        _mode = global.game_mode;
    }
    return (_mode == GAME_MODE_CLASSIC) ? "CLASSIC" : "ENDLESS";
}

function game_mode_load_best_score() {
    game_mode_ensure();
    var _best = 0;
    if (!file_exists("cushion_foul_void_save.ini")) return _best;

    var _key = game_mode_best_ini_key();
    ini_open("cushion_foul_void_save.ini");
    _best = ini_read_real("record", _key, 0);
    if (_best == 0 && _key == "best_score_endless") {
        _best = ini_read_real("record", "best_score", 0);
    }
    ini_close();
    return _best;
}

function game_mode_write_best_score(_score) {
    game_mode_ensure();
    ini_open("cushion_foul_void_save.ini");
    ini_write_real("record", game_mode_best_ini_key(), _score);
    if (global.game_mode == GAME_MODE_ENDLESS) {
        ini_write_real("record", "best_score", _score);
    }
    ini_close();
}

function game_mode_read_saved_best_score() {
    game_mode_ensure();
    if (!file_exists("cushion_foul_void_save.ini")) return -1;
    ini_open("cushion_foul_void_save.ini");
    var _value = ini_read_real("record", game_mode_best_ini_key(), -1);
    ini_close();
    return _value;
}

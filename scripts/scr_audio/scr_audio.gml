/// @description Short, locally authored gameplay sound cues.
/// User-facing SFX gain is persisted independently of the on/off compatibility
/// flag.  Keep the value as an integer percentage so both settings panels can
/// share the same hitbox and display without accumulating floating point drift.
function audio_volume_init() {
    if (!variable_global_exists("audio_volume_percent")) global.audio_volume_percent = 100;
    if (!variable_global_exists("audio_volume_ready")) {
        if (file_exists("cushion_foul_void_save.ini")) {
            ini_open("cushion_foul_void_save.ini");
            global.audio_volume_percent = ini_read_real("record", "audio_volume", global.audio_volume_percent);
            ini_close();
        }
        global.audio_volume_percent = clamp(round(global.audio_volume_percent), 0, 100);
        global.audio_volume_ready = true;
    }
    global.audio_enabled = global.audio_volume_percent > 0;
    return global.audio_volume_percent;
}

function audio_volume_get() {
    audio_volume_init();
    return clamp(global.audio_volume_percent, 0, 100) / 100;
}

function audio_volume_set(_percent) {
    audio_volume_init();
    var _next = clamp(round(_percent), 0, 100);
    if (_next == global.audio_volume_percent) return _next;
    global.audio_volume_percent = _next;
    global.audio_enabled = _next > 0;
    ini_open("cushion_foul_void_save.ini");
    ini_write_real("record", "audio_volume", global.audio_volume_percent);
    ini_close();
    return global.audio_volume_percent;
}

function audio_cushion_pitch(_count) {
    // Rise one semitone per cushion, capped at eight semitones.
    return power(2, clamp(_count - 1, 0, 8) / 12);
}

function audio_sfx(_name, _volume = 1, _pitch = 1) {
    var _master_gain = audio_volume_get();
    if (_master_gain <= 0) return false;
    var _sound = -1;
    switch (_name) {
        case "snd_shot": _sound = snd_shot; break;
        case "snd_cushion": _sound = snd_cushion; break;
        case "snd_payout": _sound = snd_payout; break;
        case "snd_foul": _sound = snd_foul; break;
        case "snd_risk_wipe": _sound = snd_risk_wipe; break;
        case "snd_item": _sound = snd_item; break;
    }
    if (_sound == -1) {
        global.audio_last_status = "MISSING " + _name;
        return false;
    }
    if (!audio_group_is_loaded(audiogroup_default)) {
        global.audio_last_status = "GROUP NOT LOADED";
        return false;
    }
    var _voice = audio_play_sound(_sound, 10, false, clamp(_volume, 0, 1) * _master_gain, 0, _pitch);
    global.audio_last_status = (_voice == -1) ? "PLAY FAILED " + _name : "PLAYING " + _name;
    return _voice != -1;
}

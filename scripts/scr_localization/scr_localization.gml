/// Shared language state and compact UI copy. language 0 = English, 1 = Korean.
function lang_init() {
    if (!variable_global_exists("language")) global.language = 0;
    if (!variable_global_exists("language_ready")) {
        if (file_exists("cushion_foul_void_save.ini")) {
            ini_open("cushion_foul_void_save.ini");
            global.language = ini_read_real("record", "language", global.language);
            ini_close();
        }
        global.language_ready = true;
    }
}

function lang_is_korean() { lang_init(); return global.language == 1; }
function lang_set(_korean) {
    global.language = _korean ? 1 : 0;
    ini_open("cushion_foul_void_save.ini");
    ini_write_real("record", "language", global.language);
    ini_close();
}
function lang_toggle() { lang_set(!lang_is_korean()); }

function tr(_en, _ko) { return lang_is_korean() ? _ko : _en; }
function lang_font_init() {
    if (!variable_global_exists("ui_pixel_glyph_map")) global.ui_pixel_glyph_map = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~클래식무한공이동위험샷파울제거알수없설정언어국영켜짐꺼완료재개메인뉴기회점최고록간격아템선택보상소유벤토리놓배율새게임오버종플레하세요빈곳다은쿠션마입니나를합테블을릭해으준비전에사용있때각도의승부모드순시작뒤로효과저장실패만워첫옮초역됨멈출습는량음까지０１２３４５６７８９려면스술값내야바텐더서와처얼굴네당구대가판늘깎릴그땐원받죠목표맞히예좋또할라겁쟁들쉼터손님브크치득벽붉적복두번여길것끝숙련누막혹친매먼중않총쌓차례살될절반났느껴질남갈납졌액줄엔안봐팽했자짝너긴혀쳐줘찾닿취날따잡겠진금앞주돌같조건핑계쫓킬골빠듯덜늦집겨돼깔큰방칠근데필둘채우짜붙명답걸추텨잃신력낼르써랑되경노쓰꿀일성확러벌감았좀쓸잘피산틀약줬겼럼읽연쯤말못져갔둔통궁직접람밌짱맘체랐웠됐쉬운틈움쉽잠깐었생훨씬밖슬꿔군셨웃런심렀봤익몇쳤끔올갑듣·↑↓";
}
function tr_mode(_mode = undefined) {
    if (is_undefined(_mode)) { game_mode_ensure(); _mode = global.game_mode; }
    return (_mode == GAME_MODE_CLASSIC) ? tr("CLASSIC", "클래식") : tr("ENDLESS", "무한");
}
function tr_item(_item) {
    switch (_item) {
        case 1: return tr("Move", "공 이동");
        case 2: return tr("Risk Shot", "위험 샷");
        case 3: return tr("Remove foul", "파울 제거");
    }
    return tr("Unknown", "알 수 없음");
}

/// Short, gameplay-facing item copy used by hover tooltips. Keep these lines
/// compact so the native 8x12 pixel atlas stays legible at 1x scale.
function tr_item_effect(_item) {
    switch (_item) {
        case 1: return tr("Place cue ball in an open spot.", "빈 곳에 공을 놓습니다.");
        case 2: return tr("Next shot: 10x per cushion.", "다음 샷은 쿠션마다 10배입니다.");
        case 3: return tr("Remove all foul balls for this turn. They return afterward.", "이번 턴 동안 파울 공을 모두 치웁니다. 턴이 끝나면 돌아옵니다.");
    }
    return tr("Unknown item.", "알 수 없는 아이템입니다.");
}
function tr_item_hint(_item) {
    switch (_item) {
        case 1: return tr("Click the table to place.", "테이블을 클릭해 놓으세요.");
        case 2: return tr("Use before lining up a shot.", "샷을 준비하기 전에 사용하세요.");
        case 3: return tr("Use when a foul ball appears.", "파울 공이 있을 때 사용하세요.");
    }
    return "";
}

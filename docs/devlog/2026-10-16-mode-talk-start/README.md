# 모드 선택 대화 동작과 START 오류

## 작업 전

사용자 보고: STORY, ENDLESS, CLASSIC 모두 START 후 `obj_cue`의 Step에서 `global.story_match_over` 미설정 오류가 발생했다. 오류 경로는 `story_versus_is_human_turn()` 59행이다. 모드 선택 시 캐릭터는 눈깜빡임 idle만 재생했다.

수정 전 `tools/capture_startup.ps1`로 `Build/final_project.win` 실행 화면을 촬영하려 했지만, Windows의 `{잘못된 DLL 재할당}` 오류로 Runner가 실행되지 않았다. 실제 게임 화면·영상은 촬영하지 못했다.

## 작업 후

모드 버튼을 클릭하면 72프레임 동안 기존 `spr_assistant_desk_talk`의 말하는 표정 프레임을 idle 얼굴 위에 표시한 뒤 idle로 돌아간다. 기존 말하기 에셋의 불투명 배경과 별도 책상은 표시하지 않는다.

일반 게임 룸의 `rules_init()`이 스토리 경기 상태를 초기화하도록 해 `obj_cue`가 없는 전역 변수를 읽지 않도록 했다. STORY 룸은 기존 `story_versus_init()`에서 해당 상태를 설정한다.

수정 후에도 동일한 Runner DLL 오류가 발생해 실제 after 화면·영상은 촬영하지 못했다. 따라서 말하기 표정의 실제 시각적 정합성과 세 모드의 런타임 전환은 아직 사용자 실행으로 확인해야 한다.

## 확인

- GameMaker Igor VM 컴파일 성공.
- `python tools/validate_project.py`, `python tools/validate_mode_menu_assets.py`, `python tools/test_game_mode_rules.py` 통과.

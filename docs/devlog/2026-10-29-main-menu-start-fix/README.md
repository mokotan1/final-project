# 메인 메뉴 시작 복구 (2026-10-29)

## 수정 전

- `before/menu.png`, `before/story-flow.mp4`: 최신 `Build/final_project.win`을 실행하면 메뉴 대신 50합 검증 경기로 바로 이동했다.
- 원인: `obj_story_intro`의 Create 이벤트에 하네스용 `room_goto(rm_story_ai_verify); exit;`가 남아 있어 저장 파일에 따른 정상 분기와 메뉴 이동을 건너뛰었다.

## 수정과 확인

- 시작 객체에서 하네스용 강제 이동 세 줄을 제거했다.
- `tools/test_first_story_launch.py`와 `tools/validate_project.py`에 시작 객체의 강제 검증 장면 이동을 막는 검사를 추가했다.
- `after/menu.png`, `after/story-flow.mp4`: 새 빌드의 1280×720 화면에서 메인 메뉴가 나타났고 시작 버튼을 통해 게임으로 이동했다. 동일한 Runner 촬영 절차를 사용했다.
- `python tools/validate_project.py`와 시작 경로 관련 두 검사는 통과했다. `python tools/test_first_story_launch.py` 전체는 현재 메뉴 코드와 맞지 않는 오래된 문자열 검사에서 실패한다. 실패 지점은 `else if (menu_hover_story) { menu_selected_story = true`이며 이번 수정과 무관하다.
- Igor VM 컴파일 통과. 수정 빌드: `Build/CushionChallenge-2026-10-29-menu-fix.win`.

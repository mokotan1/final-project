# 스토리 첫 대전 AI 턴 수정

## 작업 전

- 스토리 첫 대전에서 바텐더의 처음 두 턴은 `obj_story_versus_game`이 샷 없이 넘기도록 되어 있었다. 300점 목표를 그 전에 채우면 AI가 한 번도 타격하지 않는다.
- 코드 수정 전 `tools/capture_story_ai.ps1`로 기존 `Build/final_project.win` 실행을 시도했으나 Windows `{잘못된 DLL 재할당}` 오류로 Runner 창이 열리지 않았다. `before/`에 실제 게임 스크린샷·영상은 없다.

## 작업 후

- 첫 두 바텐더 턴을 자동 패스하던 분기를 제거했다. 플레이어의 첫 샷이 끝난 뒤 바텐더 차례가 되면 기존 AI 샷 선택을 거쳐 1초 후 타격을 시도한다.
- `tools/test_story_versus.py`에 첫 바텐더 턴 자동 패스가 다시 들어오지 않도록 검사를 추가했고, 이 검사와 `tools/validate_project.py`, GameMaker Igor VM 컴파일은 통과했다.
- `tools/test_first_story_launch.py`는 이번 변경과 무관한 기존 메뉴 입력 코드의 문자열 검사(`menu_hover_story`)에서 실패했다.
- 새 `Build/final_project.win`으로 다시 촬영하려 했으나 같은 Windows `{잘못된 DLL 재할당}` 오류가 발생했다. `after/`에 실제 화면·영상은 없으며 첫 AI 샷의 런타임 실행은 확인되지 않았다.

# 모드 선택 메뉴 구현

## 작업 전 기록

`rm_menu`의 모드 선택 화면은 기존 `spr_mode_endless`·`spr_mode_classic` 전면 이미지와 별도 스토리 버튼, 텍스트 정보 패널로 구성되어 있다. 이번 작업은 준비된 찬장 배경과 STORY·ENDLESS·CLASSIC·START·BACK 에셋을 실제 메뉴에 연결한다.

작업 전 `Build/final_project.win`을 `tools/capture_startup.ps1`로 실행해 화면을 촬영하려 했으나 `Runner.exe` 실행 단계에서 Windows `{Illegal System DLL Relocation}` 오류가 발생했다. 따라서 `before/`에는 실제 게임 스크린샷이나 영상이 없다. 이 폴더에 추후 넣는 리소스 이미지는 실제 게임 캡처와 구분해 표시한다.

## 작업 후 기록

모드 선택 화면을 `spr_mode_select_bg`와 등록된 버튼 스프라이트로 교체하고, 책상 전경이 포함된 `spr_assistant_desk_talk`를 6프레임으로 순환 표시했다. 선택한 모드의 짧은 설명을 버튼 아래에 표시하며, START·BACK·STORY 입력과 키보드 선택을 기존 흐름에 연결했다.

후속 검토에서 STORY도 선택 상태로 통합했다. STORY를 선택하면 설명과 강조 테두리가 바뀌며 START 또는 Enter로 기존 story opening으로 진입한다. 설명은 조수와 겹치지 않는 오른쪽 하단으로 옮겼고, 대화 애니메이션은 `frames.json`의 600/100/180/330/280/450ms 타이밍을 60fps 기준 36/6/11/20/17/27 프레임으로 반영했다. 스토리 오프닝의 시작 안내도 영어/한국어 `tr()` 문자열을 사용한다.

정적 검증 결과:

- `python tools/validate_modes.py` 통과
- `python tools/validate_presentation_resources.py` 통과
- 메뉴 오브젝트의 에셋 참조와 `application_start_story()` / `application_start_game(menu_selected_mode)` 참조 확인

작업 후 동일한 `tools/capture_startup.ps1` 실행을 재시도했으나, 게임 실행 단계에서 기존과 같은 Windows `{Illegal System DLL Relocation}` 오류로 `Runner.exe`가 시작되지 않았다. 따라서 `after/`에도 실제 게임 스크린샷과 영상은 생성되지 않았다.

`after/resource_composite_preview.png`는 배경·조수 첫 프레임·버튼 PNG를 코드의 좌표대로 합성한 **리소스 미리보기**다. 실제 게임 화면 캡처나 설명 문구의 런타임 렌더링은 아니다.

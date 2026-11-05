# GMS 원본 기준 Unity 이식 점검 — 2026-11-05

## 직접 확인한 원본과 화면

- 현재 `final_project.yyp`를 GameMaker Igor VM으로 컴파일했다. Igor가 실제 출력 경로로 `Build/final_project.win`을 보고했고 컴파일은 성공했다. 이 빌드는 이전 같은 이름의 빌드를 대체했다. SHA-256: `149593569084a92b12ad75c58d5e98cad4e5654f170c66baf9eb1b430676e3e4`.
- 같은 빌드를 GameMaker Runner로 실행해 [실제 시작 메뉴](before/gms/menu.png)를 촬영하고 확인했다. 1280×720 캡처다. 스토리 화면 자동 촬영은 다른 창에 가려 실패했다. 실패한 캡처는 비교 자료에서 제외했다. 이 메뉴 화면만으로 플레이나 규칙 일치를 주장할 수 없다.
- 이전 작업에서 촬영한 [Unity Endless 화면](../2026-11-04-unity-gameplay-startup/after/gameplay-rendered.png)을 직접 확인했다. 이 자료는 오늘 촬영한 화면이 아니며 GMS와 동일 조건의 비교가 아니다.

## 실제 소스 대조

- `objects/obj_ball/Draw_0.gml` 1–8행: 플레이어·목표·파울 스프라이트 및 RGB(100,160,255) AI 틴트. 10–33행: 3단 그림자와 `sh_ball_scroll`.
- Unity `Assets/Scripts/Gameplay/GameRoomController.cs` 107–124, 166–170, 218–236행: 세 공 이미지를 불러오나 AI 틴트·원본 그림자·스크롤 효과는 이 경로에 없다. 해당 세 PNG는 각 GMS 원본과 SHA-256이 같다. 이는 리소스 파일 비교이며 화면 표시나 동작 전체의 일치 증거는 아니다.
- `scripts/scr_story_versus/scr_story_versus.gml` 1169행 이후의 스토리 HUD·상점·대사 그리기와 Unity `GameHudPanel.cs`, `StoryShopPanel.cs`, `StoryDialoguePanel.cs`를 대조했다. Unity의 간단한 텍스트 HUD와 상점 안내, 하단 대사 패널은 원본 배치와 다르다. 원본의 상점 포인터 처리는 `objects/obj_ui/Step_0.gml` 124행 이후에 있다.
- 원본 타이틀과 모드 선택 흐름은 `objects/obj_menu/Draw_64.gml`, `Step_0.gml`에서 확인했다. Unity의 `MainMenuUiBuilder.cs`, `MainMenuController.cs`는 다른 흐름이다.

## 남은 검증

경기 장면은 현재 GMS 빌드와 Unity에서 동일 해상도·모드·상태로 새로 촬영해야 한다. 샷, 충돌, 점수 정산, 브레이크, 상점, AI와 입력 일치는 이번 정적 조사와 메뉴 화면만으로 증명되지 않는다. 게임 화면이나 동작에 관한 수정은 해당 작업의 수정 전 촬영을 먼저 확보한다.

## 저장 추적 기준 보호

- Unity EditMode의 `ExportGolden_312x15_ForPythonMirror`는 일반 실행에서 빠지는 명시적 테스트로 변경했으며, 실행하더라도 OS 임시 폴더에 후보만 쓴다. 기존 Unity 기준 파일과 GMS Runner 추적은 덮어쓰지 않는다.
- Unity EditMode 전체 결과는 37 통과, 0 실패, 명시적 내보내기 1건 건너뜀이다. 해당 테스트를 포함해 선택 실행한 결과는 4 통과다. 두 실행의 XML은 `output/golden-suite.xml`, `output/golden-green.xml`이다. Unity 기준 파일 SHA-256은 실행 전후 `0eaa947c748be6f696759f0d624c265a8b142391d9dba1cd136d85d084de0467`로 유지됐다.
- `python tools/test_physics_live_parity.py`, `python tools/test_gm_runner_unity_parity.py` 통과. 후자는 기존 저장 추적 비교이며 이번 실행에서 GMS나 Unity를 새로 측정하지 않는다. 수정 전 실패를 확인하려던 Unity 실행은 샌드박스에서 결과 전에 종료되어 실패 재현은 확인되지 않았다.
- 테스트 및 도구만 변경했으며 게임 화면·조작·규칙은 변경하지 않았다.
- 추가 독립 검토에서 `tools/gm_live_physics_trace.py`를 직접 실행하면 같은 Unity 기준을 쓸 수 있는 별도 경로가 발견됐다. 이 경로도 임시 후보 JSON을 생성하도록 수정하고 `python_mirror_simulation` 출처를 표시했다. 격리된 테스트에서 수정 전 덮어쓰기를 확인했고, 수정 후 `python tools/test_gm_live_physics_trace_output.py`가 통과했다. 이 후보는 GMS Runner 실측이 아니다.

## 사용자가 제공한 스프라이트 목록

- [GMS 스프라이트 목록](https://docs.google.com/spreadsheets/d/1MLYBjLg80lMfunNwtVvuRohyzBu7AnUasjfJ802DkDI/edit)의 11/05 요약은 등록 38종 중 동명 PNG가 Unity Assets에 있는 것을 11종, 없는 것을 27종으로 분류한다. 이는 파일명 존재 기준이며 런타임 사용이나 동일 표시 여부의 검증은 아니다.
- 목록과 대조하여 `objects/obj_cue/Draw_0.gml`이 `spr_cue`를 실제 그리는 것과 `scripts/scr_story_versus/scr_story_versus.gml`이 상점에 세 아이템 스프라이트를 참조하는 것을 직접 확인했다. 목록의 코드 미참조 항목은 정식 등록 여부만으로 실제 게임에 추가하지 않는다.

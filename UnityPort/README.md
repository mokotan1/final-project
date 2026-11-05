# Cushion Challenge — UnityPort

GameMaker `final_project`의 Unity 이식 프로토타입입니다. 원본과 **별도 프로젝트**이며, GameMaker 소스/미커밋 변경은 건드리지 않습니다.

**진행 상황:** `PORT_REPORT.md`  
**좌표/스폰 작업 일지:** `docs/devlog/2026-11-05-unity-coordinate-port/`

## 요구 사항

- Unity **6000.3.10f1** (Universal 2D 템플릿으로 생성됨)

## 열기

```powershell
unity open D:\final_project\UnityPort
```

또는 Hub에서 `UnityPort` 폴더를 선택합니다.

## 검증

```powershell
unity test D:\final_project\UnityPort --editor-version 6000.3.10f1 --mode EditMode
unity test D:\final_project\UnityPort --editor-version 6000.3.10f1 --mode PlayMode
unity build D:\final_project\UnityPort --editor-version 6000.3.10f1 --target StandaloneWindows64 --execute-method CushionChallenge.Editor.PortBuild.PerformBuild
python D:\final_project\tools\story_ai_fixture_sim.py
```

빌드 결과: `Builds/Windows/CushionChallengeUnityPort.exe`

Editor가 이미 열려 있으면 CLI `unity test`는 실패합니다. Editor를 닫거나 Test Runner에서 실행하세요.

## GMS → Unity 매핑 (주요)

| GameMaker | Unity |
|-----------|--------|
| `scr_physics` / `obj_ball_*` Step | `BilliardBallMotor`, `BilliardCushionPhysics`, `BilliardPhysicsWorld` |
| `physics_table_bounds`, rm_game table | `GameConstants`, `TableCushionLayout` |
| Room x/y (y-down) | `GameMakerDisplay`, `GameMakerBallVisual` |
| `application_spawn_ball`, `application_spawn_initial_balls` | `ApplicationBallSpawner`, `GameRoomController.ApplyEndlessSpawnLayout` |
| `story_versus_spawn_layout`, `story_versus_spawn_ball_at` | `StoryVersusSpawnLayout`, `GameRoomController.ApplyStorySpawnLayout` |
| `story_versus_init`, `story_versus_*` shot/turn | `StoryVersusSession` |
| `story_versus_break_foul_rules_suppressed` | `StoryVersusBreakRules` |
| `story_versus_show_break_assign_dialogue` | `StoryVersusSession.TryShowBreakAssignDialogue` |
| `scr_story_ai` / simulate | `StoryAiSimulator`, `StoryAiTurnPlanner`, `StoryAiShotPicker` |
| `scr_game_rules`, endless items | `EndlessRulesEngine`, `EndlessItemProgression`, `EndlessScoreMath` |
| `scr_application_commands` (subset) | `GameRoomController` input handlers, `PortSaveStore` |
| `obj_ui` Draw_64 HUD (partial) | `GameMakerGameplayHud` |
| `scr_ui_button` | *(미이식 — Unity UI 빌더 잔존)* |
| `scr_ui_pixel_text`, `lang_font_init` | `GameUiFonts` (Galmuri Resources), `GameMakerGameplayHud` labels |
| `obj_cue` | `CueAimController` |
| `obj_story_versus_game` / `obj_game` | `GameRoomController` |
| `rm_menu`, mode select | `MainMenuController`, `MainMenuUiBuilder` |
| Story intro room | `StoryIntroController`, `StoryIntroUiBuilder` |
| `obj_result` | `MatchResultPanel` *(레이아웃 비동등)* |
| Options / save | `SettingsPanel`, `PortSaveStore` |
| `application_go_to_main_menu`, scenes | `SceneFlow`, `PortScenes`, `BootSceneController` |
| Runner / live trace harness | `BilliardLiveFixtureTrace`, `BilliardGmLiveTraceTests` |
| GMS sprite assets | `Resources/GameArt/**`, `PortReferencedSpriteImport` (Editor menu) |

## 스프라이트

Unity 메뉴 **CushionChallenge → Import Referenced GMS Sprites** — GMS `scripts`/`objects`/`rooms`에서 참조된 `spr_*`만 `sprites/`에서 복사합니다.

## 조작 (현재)

- 메인 메뉴: Story / Endless / Classic
- 플레이: 마우스 조준, 좌클릭 홀드로 차지 후 릴리즈
- Story: `[1]` 이동 `[2]` Risk `[3]` 파울 제거, `Space` 대사 스킵
- Endless: 인벤/보상 키 — `GameRoomController` / `EndlessRulesEngine` 참고

## 이식 범위 (레거시)

`docs/devlog/2026-11-03-unity-port/PORT_STATUS.md` — 초기 프로토타입 범위; 최신 상태는 `PORT_REPORT.md` 우선.

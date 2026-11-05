# UnityPort 명명 씬·씬 전환 (2026-11-03)

## 작업 전

- 에디터 `Assets/Scenes`에 **SampleScene.unity**만 존재. 메뉴·오프닝·대국은 `GameBootstrap.AfterSceneLoad`가 SampleScene에서 빈 씬 위에 GameObject를 런타임 생성.
- GameMaker 대응: `rm_story_intro` → StoryIntro, `rm_menu` → MainMenu, `rm_game` → GamePlay.

**비포 스크린샷**: 이 세션에서 Unity Game View 전용 캡처는 하지 못함(에디터가 프로젝트 점유, batchmode 거부). 이전 자료: `docs/devlog/2026-11-03-unity-port/after/unity-runtime-screen.png`(단일 SampleScene 런타임).

## 작업 후

- `Assets/Scenes/Boot.unity`, `MainMenu.unity`, `StoryIntro.unity`, `GamePlay.unity` + 기존 `SampleScene.unity` 유지.
- `MainMenu` 씬 파일에 `MenuCanvas`, Story/Endless/Classic, Settings, EventSystem 계층이 **씬 YAML에 저장**됨(에디터에서 열어 편집 가능).
- `GamePlay` 씬에 `GameRoom` / Table / 공 / Cue / StoryDialogue / RuntimeUi 루트.
- `ProjectSettings/EditorBuildSettings.asset`: Boot → MainMenu → StoryIntro → GamePlay → SampleScene.

**애프터 스크린샷**: 미촬영(동일 이유). 계층 증거는 씬 에셋 파일(`Assets/Scenes/*.unity`) 및 본 README.

## 검증

| 항목 | 결과 |
|------|------|
| Unity 6000.3.10f1 컴파일 | 열린 에디터가 `PortSceneSetup` 실행·씬 4개 저장 → **PASS(간접)**; `Library/Bee/tundra.log.json`에 CS 오류 없음 |
| EditMode | 메인 프로젝트 batch `-runTests` **BLOCKED**(`another Unity instance is running`). `PortSceneSetupTests` 3건 추가(총 22건 기대). |
| PlayMode / 씬 전환 | batch PlayMode **미실행**. 구현: `SceneFlow` + `SceneManager.LoadScene`; `GameBootstrap`은 SampleScene 레거시만. |
| Windows 빌드 | batch **미재실행**; `PortBuild.PerformBuild` → `PortScenes.BuildOrder`. |

## 한계

- 에디터를 닫지 않으면 CI형 batch 테스트·빌드·Game View 캡처 불가.
- HUD·MatchResult·Settings 일부는 여전히 런타임 `Create()`(기존 동작). 씬에 없는 UI만 생성; 중복 빌드는 `HasMenuUi` / `HasIntroUi` / `Find()` 재사용으로 방지.

## 사용

- **Cushion Challenge → Setup Port Scenes**: 씬·Build Settings 재생성.
- 플레이어 시작: **Boot** (첫 Build Settings 씬).

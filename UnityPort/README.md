# Cushion Challenge — UnityPort

GameMaker `final_project`의 Unity 이식 프로토타입입니다. 원본과 **별도 프로젝트**이며, GameMaker 소스/미커밋 변경은 건드리지 않습니다.

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
unity build D:\final_project\UnityPort --editor-version 6000.3.10f1 --target StandaloneWindows64 --execute-method CushionChallenge.Editor.PortBuild.PerformBuild
python D:\final_project\tools\story_ai_fixture_sim.py
```

빌드 결과: `Builds/Windows/CushionChallengeUnityPort.exe` (EditMode 16 tests)

## 이식 범위

자세한 완료/미완료 목록은 `docs/devlog/2026-11-03-unity-port/PORT_STATUS.md`를 참고하세요.

## 조작 (현재 프로토타입)

- 메인 메뉴: Story / Endless / Classic 버튼
- 플레이: 마우스 조준, 좌클릭 홀드로 차지 후 릴리즈로 샷
- Endless: `[2]` 인벤 Risk arm (이동·파울 제거 UI 미완)
- Story: `[1]` 이동 `[2]` Risk `[3]` 파울 제거 (플레이어 턴), `Space` 대사 스킵

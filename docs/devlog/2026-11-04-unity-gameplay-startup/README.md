# Unity 이식 후속 작업: 게임 시작 오류 (2026-11-04)

## 수정 전

- Unity 6000.3.10f1, `Assets/Scenes/GamePlay.unity`, Play 모드에서 1280×720 Game View를 Pipeline으로 촬영했다. `before/gameplay.png`는 검은 화면이다.
- 콘솔: `MissingComponentException: There is no 'Rigidbody2D' attached to the "PlayerBall"` → `GameRoomController.SpawnBall` → `BuildRoom` → `Awake`. 초기화 중단으로 정상 플레이 및 조작 영상 촬영은 불가능했다.
- GameMaker 기본 빌드의 SHA-256이 물리 하네스 빌드와 동일하므로 정상 게임 기준으로 사용하지 않았다. Runner는 일반 데스크톱 환경 검사에서 실행 가능했다.

## 후속 우선순위

- 정상 게임 시작과 메뉴 버튼 연결을 검증한다.
- 큐 드래그 거리·방향·입력 잠금, 대사 클릭/Enter, 상점 클릭을 원본과 대조한다.
- 브레이크 선공과 AI 아이템 구매·복구 위험 샷의 순서를 원본과 대조한다.
- 추가 물리 샷과 점수 정산, 모드별 규칙, 화면·대사·음향 및 저장을 실제 플레이로 검증한다.

## 1차 수정 후

- `after/gameplay.png`: 같은 Unity GamePlay 씬·1280×720에서 HUD가 생성됐다. 당구대와 공은 보이지 않아 플레이 가능한 상태가 아니며 원인을 추가 조사 중이다.
- 기존 씬 공에 Rigidbody2D가 없을 때 Unity의 null 검사로 추가한다. 해당 씬을 여는 PlayMode 회귀 검사는 수정 전 MissingComponentException 실패, 수정 후 공 5개와 HUD 생성 확인 PASS로 보고됐다.
- 수정 전에는 초기화 실패로 조작 영상을 촬영할 수 없었다. 수정 후 동등한 조작 영상도 아직 없다.

## 렌더링 수정과 검증

- 다중 Sprite 리소스를 불러와 1 pixel/unit로 생성하고 당구대와 공에 비조명 재질을 적용했다. 생성된 Sprite는 씬 종료 때 해제한다. `after/gameplay-rendered.png`는 실제 Unity Game View 캡처다.
- `GamePlaySceneInitializationTests` PlayMode 3/3 PASS: 공과 HUD 초기화, 비조명 재질, 씬 종료 Sprite 해제. Unity 재컴파일 오류 없음.
- Game View에서 당구대와 공이 나타나는 것을 확인했다. 플레이 영상은 촬영하지 않았다. 수정 전에는 공이 보이지 않아 동등한 조작 영상을 만들 수 없었다.
- 세로 좌표 방향은 원본과 아직 다르다. 원본과 동일한 입력·화면·물리 검증, 실제 Windows standalone 빌드는 미완이다.
- 저장된 메뉴 버튼의 런타임 콜백 누락은 코드 및 씬 정적 검토에서 발견했으며 수정 전이다. 큐 조작과 AI 아이템 순서도 원본과 다르다.

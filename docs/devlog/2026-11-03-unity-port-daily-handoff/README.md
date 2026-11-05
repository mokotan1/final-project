# Unity 이식 작업 일지 및 이어서 할 일 — 2026-11-03

## 목표
GameMaker 원본 게임을 Unity에서 화면, 조작, 물리, 규칙, AI, 대사, 음향까지 동일하게 재현한다. 현재는 이식 중이며 완전 일치는 확인되지 않았다.

## 오늘 작업
- `UnityPort`에 Boot, MainMenu, StoryIntro, GamePlay 씬과 빌드 순서를 구성했다. HUD·결과·설정 등 일부 구성은 아직 실행 시 생성된다. 상세: `../2026-11-03-unity-port-scenes/README.md`.
- 메뉴, 대전, 50합 스토리, 상점·아이템, 반응 대사, 일부 AI, 결과 화면, 오디오와 갈무리 글꼴을 이식했다. 실제 GameMaker와 전체 동작이 같다는 뜻은 아니다.
- Unity Pipeline 패키지를 설치하고 열린 UnityPort 에디터에 연결해 테스트와 Game View 캡처에 사용했다.
- GM `lengthdir_y` 방향과 live 물리 처리 순서 및 수치 연산의 차이를 조사해 Unity에 반영했다. AI 시뮬레이션과 실제 플레이 물리를 별개 경로로 유지한다.
- GM Runner에 실측 하네스를 연결해 312°/파워 15, 고정 공 배치의 284프레임 기록을 생성하고 Unity 기록과 비교했다. 이 한 사례의 비교 테스트는 오차 허용치 0.06 기준으로 통과했다. 상세와 자료: `../2026-11-03-unity-live-gm-parity/README.md`.

## 검증과 한계
- 2026-11-03 종료 정리 시 `python tools/test_gm_runner_unity_parity.py` 재실행 PASS. 이 검증은 한 가지 고정 샷에 한정되며 완전한 물리 일치를 증명하지 않는다.
- Cursor는 관련 EditMode 및 PlayMode 테스트 통과를 보고했다. 전체 게임 플레이 통합 검증과 최신 Windows 실행 파일 재빌드는 이번 종료 정리에서 다시 실행하지 않았다.
- 비교 하네스의 점수 0은 `shot_pending_points`를 확정하지 않은 기록이므로 실제 대전 최종 득점이 같다는 증거가 아니다.
- GameMaker와 Unity의 동일 입력 동시 영상은 없다. Unity 게임 화면 캡처는 별도 물리 일지에 있으나, 이번 마지막 물리 변경에 대한 동일 조건 전후 영상은 촬영하지 못했다.

## 다음 작업
1. GM Runner와 Unity의 추가 배치·파워·충돌·파울·실제 확정 점수를 같은 입력으로 비교하고 플레이 모드 전체 경로까지 검증한다.
2. 스토리 15스테이지, 누락된 대사·도움말·AI 및 각 모드의 아이템과 결과 처리를 원본과 대조해 이식한다.
3. 화면 구성·픽셀 글꼴·셰이더·음향·저장 방식과 에셋을 GameMaker와 비교해 누락을 채운다.
4. 동일 조건의 GameMaker/Unity 실제 화면과 움직임을 촬영하고, 전체 씬 전환·PlayMode 및 Windows 빌드를 검증한다.

참고: `../2026-11-03-unity-port/PORT_STATUS.md`에는 이전 단계 설명이 남아 있어 최신 물리 상태는 이 일지와 `../2026-11-03-unity-live-gm-parity/README.md`를 우선 확인한다.

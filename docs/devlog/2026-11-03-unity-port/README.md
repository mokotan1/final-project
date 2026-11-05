# Unity 이식 (2026-11-03)

## 작업 전 (GameMaker 기준)

- `before/gm-menu-reference.png`: 기존 메인 메뉴 UI 참고 캡처(히스토리 자료).
- `before/gm-story-reference.png`: 스토리 50합 HUD 참고 캡처(2026-10-22 final-reviewed).

GameMaker Runner를 이 세션에서 다시 촬영하지 않았다. AGENTS.md 비포 촬영은 GameMaker 쪽 미커밋 변경을 건드리지 않기 위해, 동일 모드·해상도의 최근 devlog 자료를 before 기준으로 사용했다.

## 작업 후 (UnityPort)

- `after/unity-runtime-screen.png`: 빌드 exe 4초 기동 중 **데스크톱 전체** 캡처(1280×720 전용 Game View 아님).
- `before/unity-physics-baseline/`, `after/unity-physics-baseline/`: Pipeline Game View 1280×720 (GamePlay Play 모드; Game 창 비포커스 시 빈 화면일 수 있음).
- EditMode **23** tests — Pipeline `test run --mode editor` **23/23 PASS** (4차).

## 변경 요약 (4차)

- GM `scr_physics`와 맞춤: 쿠션/pair lock 프레임, ball-ball restitution, `physics_begin_rule_contact`·양방향 규칙 접촉, scored 후 쿠션 무시, 배치 간격 +2.

## 변경 요약 (3차)

- Endless: **보상 선택 UI**, **place_mode**, 인벤 파울 제거, best **PlayerPrefs** 저장.
- Story: **AI recovery risk**, AI **상점**, **브레이크/무샷 패스**, 턴 배너·입력 잠금.
- **오프닝**(OPN-01~06), **설정**(볼륨), **Galmuri**·**SFX** subset, 오프닝 스프라이트 Resources.

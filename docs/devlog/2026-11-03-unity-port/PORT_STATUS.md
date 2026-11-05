# UnityPort 이식 상태

마지막 갱신: 2026-11-03 (8차 — GM live 물리 복원 + 프레임 trace 회귀)

## 8차 — GM live 물리 · trace 회귀

| 영역 | 내용 |
|------|------|
| **회귀 복원** | `BilliardLivePhysics` / `BilliardPhysicsWorld` — pre-step 이동, cushion lock 3, pair lock 3, cloth bounds + `obj_cushion` 세그먼트 반사 |
| **AI sim** | `StoryAiSimulator` **별도 유지** (bounds-only, lock 없음) |
| **회귀** | `gm_live_physics_312_15.json` + `BilliardGmLiveTraceTests`; `tools/test_physics_live_parity.py` |
| **7차 회귀 기록** | `docs/devlog/2026-11-03-unity-live-gm-parity/before/regression-7th-live-vs-gm.md` |
| **미완** | GM Runner live JSON vs golden 동시 대조, PlayMode CLI 0건 이슈, 전체 스토리/UI 이식 |

## 프로젝트 위치

- `D:\final_project\UnityPort` — GameMaker `final_project.yyp`와 분리된 Unity 6000.3.10f1 (URP 2D) 프로젝트.
- 원본 GameMaker **미커밋 변경 수정 없음** (`python tools/validate_project.py` PASS).

## 이번 세션(7차) — 312°/15 live PlayMode · GM harness

| 영역 | 내용 |
|------|------|
| **근본 원인** | Unity live가 `TableCushionSegment` overlap + **cushion lock 3**으로 harness/sim(`story_ai_simulate`) 대비 쿠션 **5 vs 6** |
| **수정** | `BilliardBallMotor` — GM sim과 동일 **cloth bounds만** 쿠션 집계·반사; 세그먼트 물리 스캔 제거; parity 경로 cushion lock 제거 |
| **프로브** | `BilliardLiveShotProbe` + PlayMode `BilliardLiveParityTests` (312°/15, probe 3종) |
| **GM Runner** | `Build/story_50_runtime_test.win` → `STORY50_RUNTIME_TEST PASS` (`docs/devlog/2026-11-03-unity-port/harness_stdout_7th.txt`) |
| **비포·애프터** | `before/live-parity-reference.md`, `after/live-parity-gameplay-1280x720.png` |

## 이번 세션(6차) — 312°/15 harness · sim/live 방향

| 영역 | 내용 |
|------|------|
| **원인** | GM `lengthdir_y`는 **−sin** (y-down)인데 Unity/Python mirror는 **+sin** 사용 → 312°/15가 2쿠션·파oul 경로로 어긋남 |
| **수정** | `GameConstants.LengthDir` — sim, `StoryAiShotPicker` ray, AI `AngleToVector` |
| **라이브 물리** | `BilliardBallMotor` — GM과 동일 **픽셀/Step** (`Velocity`에 `fixedDeltaTime` 미곱) |
| **테스트** | `SixCushionFixtureProbe_MatchesGameMakerHarness`, probe 서명 `312:15:6:True:False`, EditMode **33/33 PASS** |
| **Python** | `story_ai_fixture_sim.py` −sin + foul 스캔을 GM `story_ai_fixture_has_recovery_foul_shot`처럼 전수 |

## 이번 세션(5차) — obj_cushion · 스토리 AI · 비교 테스트

| 영역 | 내용 |
|------|------|
| **obj_cushion** | `TableCushionSegment` + `TableCushionLayout` — rm_game 인스턴스 좌표·스케일(spr_cushion 64×32) 반영; `BilliardBallMotor` bounds 이후 세그먼트 반사(`BilliardCushionPhysics`, GM `physics_resolve_cushion_collision`) |
| **스토리 AI** | `StoryAiShotPicker.RayFoulRisk` → GM `story_ai_ray_foul_risk`(900px 세그먼트, 40px 밴드); catch-up/ahead pick EditMode 검증 |
| **상태·catch-up** | `StoryAiTier` + `StoryAiParityTests` — 50R, R16, 10k/5k gap, tier 1, 6쿠션+`AiCompetitiveGap` 밴드 (harness `story_50_runtime_harness.gml` 블록과 동일 점수 조건) |
| **동일 입력 테스트** | `StoryAiDeterministicInputTests` — fixture 좌표 + probe 샷 서명(312°/15 등) Unity sim 기준 고정 |
| **비포·애프터** | `before/unity-cushion-story-baseline/`, `after/unity-cushion-story-baseline/` (+ `Assets/CaptureDevlog/`) |

## 이번 세션(4차) — 물리·점수 접촉

| 영역 | 내용 |
|------|------|
| **BilliardBallMotor** | 쿠션 lock **3**프레임, pair lock **3**, `min(restitution)` |
| **GameRoomController** | 규칙 접촉 lock **30**, striker↔target/foul, shot_scored 후 쿠션 무시 |
| **배치** | `BallPlacementUtility` 간격 **+2** |
| **테스트** | `BilliardPhysicsParityTests` 상수 |

## 여전히 골격/미완 (완전 동일 아님)

- **GM Runner harness**: `story_50_runtime_test.win` **실기 PASS** (six-cushion-fixture sim 블록). Unity PlayMode live probe **312°/15 PASS**.
- **Headless sim vs live 쿠션**: Unity live는 harness/sim과 **동일 bounds 규칙**으로 정렬(7차). GM **라이브** `physics_cushion_lock`·obj_cushion 반사와의 프레임 단위 동시 캡처는 **미실행**.
- 15 스테이지 스토리 모드 전체, `tr()` localization, gentle AI 대사·입력 help, 픽셀 atlas/셰이더, `obj_result` 연출, GM INI vs PlayerPrefs.
- 쿠션 **스프라이트 렌더**·Physics2D BoxCollider(현재 논리 bounds + overlap 스캔만).
- Galmuri 동적 글리프 / GM `scr_ui_pixel_text` 수준.
- Windows standalone 재빌드·GM Runner 동시 캡처 **미실행**.

## 검증 (2026-11-03 Cursor — 7차)

| 항목 | 결과 |
|------|------|
| GM Runner `story_50_runtime_test.win` | **PASS** (`harness_stdout_7th.txt`) |
| Pipeline EditMode | **33/33 PASS** |
| Pipeline PlayMode `BilliardLive` | **2/2 PASS** |
| `python tools/story_ai_fixture_sim.py` | **PASS** |
| `python tools/validate_project.py` | **PASS** |
| GM live vs Unity 동일 프레임 캡처 | **미실행** |
| Windows standalone 재빌드 | **미실행** |

## 검증 (2026-11-03 Cursor — 6차)

| 항목 | 결과 |
|------|------|
| Pipeline EditMode | **33/33 PASS** |
| `python tools/story_ai_fixture_sim.py` | **PASS** (GM lengthdir_y) |
| PlayMode 312°/15 | **7차에서 BilliardLive 2/2 PASS** |

## 검증 (2026-11-03 Cursor — 5차)

| 항목 | 결과 |
|------|------|
| Pipeline `unity cmd test run --mode editor` (UnityPort :7800) | **31/31 PASS** (~5.1s) |
| Pipeline `recompile` | **PASS** |
| `python tools/validate_project.py` | **PASS** |
| `python tools/story_ai_fixture_sim.py` | **PASS** (Python mirror; probe 312/15는 Unity 서명과 동일 foul 경로) |
| PlayMode Game View 1280×720 | 캡처 시도 — Editor Game view 미포커스 시 blank 가능; `after/…/gameplay-playmode-1280x720.png` 저장 |
| GM Runner vs Unity 동시 parity | **미실행** |

## 검증 (2026-11-03 Cursor — 4차)

| 항목 | 결과 |
|------|------|
| EditMode | **23/23 PASS** (이후 테스트 추가로 31개로 증가) |

## 검증 한계

- UnityPort는 GM과 **완전 동일** 주장하지 않음 — EditMode·fixture·PlayMode live probe(7차)까지 증명. GM **라이브** obj_ball Step(쿠션 lock)과 Unity bounds parity는 의도적 sim 정렬.
- batch `unity test` 는 동일 프로젝트 Editor가 열려 있으면 거부 — Pipeline `unity cmd test run` 사용.

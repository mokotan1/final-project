# 7차 — 312°/15 라이브 물리 parity (2026-11-03)

## 작업 전

- `before/live-parity-reference.md`: PlayMode 프로브 도입 전 상태 — `BilliardBallMotor`가 `ResolveCushionSegments`에서 쿠션을 **중복 집계**하고, GM `physics_cushion_lock`(3프레임)으로 **story AI sim/harness보다 쿠션이 적게** 나올 수 있음(312°/15에서 live 5 vs sim 6).
- GameMaker Runner 재촬영 없음(미커밋 GML 보호). 동일 harness 빌드(`Build/story_50_runtime_test.win`)로 **sim 블록** 검증.

## 작업 후

- `after/live-parity-gameplay-1280x720.png`: GamePlay 씬 Main Camera 1280×720 (Pipeline `game_view`, source=camera).
- `harness_stdout_7th.txt`: `STORY50_RUNTIME_TEST PASS` (six-cushion-fixture 포함, `six-cushion-fixture` failure 없음).

## 변경 요약

| 항목 | 내용 |
|------|------|
| **근본 원인** | (1) 세그먼트 overlap이 bounds와 함께 쿠션 이벤트·반사를 유발 (GM은 obj_cushion 반사만, 집계는 bounds). (2) 3프레임 cushion lock이 **story_ai_simulate**(harness)에는 없어 live만 쿠션 누락. |
| **수정** | `BilliardBallMotor`: bounds만 쿠션 집계·반사; 세그먼트 스캔 제거; sim parity 경로에서 cushion lock 제거. |
| **검증** | `BilliardLiveShotProbe` + PlayMode `BilliardLiveParityTests` — 312°/15 → ≥6쿠션·타겟·비파oul, probe 3종 EditMode 서명과 일치. |

## 검증

| 항목 | 결과 |
|------|------|
| GM Runner `story_50_runtime_test.win` | **PASS** (`harness_stdout_7th.txt`) |
| Pipeline EditMode | **33/33 PASS** |
| Pipeline PlayMode `BilliardLive` | **2/2 PASS** |
| `python tools/story_ai_fixture_sim.py` | **PASS** |
| `python tools/validate_project.py` | **PASS** |

## 미검증·한계

- GM **라이브** `obj_ball` Step(쿠션 lock 3)과 Unity PlayMode **프레임 단위 동시 녹화** 비교는 미실행. harness·Unity 검증 축은 **story_ai_simulate / EditMode sim** 과 동일.
- Game View 창 포커스 캡처(HUD 포함) 미실행 — camera 소스 PNG만 확보.
- Windows standalone 재빌드·16스테이지 전체·Galmuri 동적 글리프 등 PORT_STATUS 미완 항목 그대로.

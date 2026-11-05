# GM live vs Unity live parity (9차)

마지막 갱신: 2026-11-03 (parity fix)

## Before

- `before/regression-7th-live-vs-gm.md`: Unity live가 AI sim(세그먼트 AABB)에 맞춰져 GM Runner와 불일치.
- `before/`: Unity Game View 1280×720 (`after/game-view-1280x720.png` 재사용).

## After

- **GM Runner 실측 harness**: `tools/build_physics_live_trace.ps1` + `tools/run_physics_live_trace.ps1` + `tools/physics_live_trace_harness.gml` (End Step 프레임 캡처).
- **실측 산출물**: `after/gm-runner-trace/gm_live_physics_312_15_runner.json` (284 frames, 312°/15, cushions=5, hit_target, foul=false, score=0).
- **Unity live physics**: `BilliardLivePhysics` — GM Runner End Step와 동일 순서 (**scr_physics → position += hspeed/vspeed**), cloth bounds만 반사, **GameMakerFloat32** (`GameMakerFloat.cs`).
- **회귀 golden**: `UnityPort/Assets/Tests/Fixtures/gm_live_physics_312_15.json` + `gm_live_physics_312_15_gm_runner.json`.
- **프레임 parity**: `tools/compare_gm_unity_physics_trace.py` / `tools/test_gm_runner_unity_parity.py` — **PASS** (284 frames, tolerance 0.06).
- **trace outcome score**: harness와 동일하게 `shot_pending_points` 미적용 → **score=0** (Unity fixture trace; 실제 스토리 득점은 `StoryVersusSession` 경로).

## 검증 (실행됨)

| 항목 | 결과 |
|------|------|
| `tools/test_gm_runner_unity_parity.py` | **PASS** |
| `compare_gm_unity_physics_trace.py` → `after/gm-vs-unity-trace-diff.md` | **MATCH** |
| Pipeline EditMode `BilliardGmLiveTraceTests` + `BilliardPhysicsParityTests` | **PASS** |
| Pipeline PlayMode `BilliardGmLiveParityTests` | **PASS** |
| `after/game-view-1280x720-parity-fix.png` | Unity Game View 캡처 |

## 원인 (요약)

1. Unity가 **pre-step 이동 → friction** 순서(구 AI sim 관습)였고, GM Runner End Step 캡처는 **friction/bounds/collision 후 이동**과 float32 `lengthdir`/`point_distance` 체인.
2. ~0.03px/프레임 drift는 double `lengthdir` + 잘못된 step 순서의 누적.
3. 쿠션 반사 프레임 어긋남(예: step 15) → 프레임 수 286 vs 284, PlayMode 이중 StepWorld.
4. trace outcome **score 3200**은 `NormalPointsForCushions`를 fixture에 적용한 것; GM harness는 `shot_pending_points==0`.

## 미완 (이식 전체)

- PORT_STATUS: 스토리 15스테이지 전체, `tr()` localization, gentle AI 대사, 픽셀 atlas/셰이더, `obj_result` 연출, GM INI vs PlayerPrefs, 쿠션 스프라이트 렌더, Galmuri 동적 글리프, Windows standalone vs GM 동시 영상 회귀.
- `obj_cushion` **스프라이트 Collision** (Runner에 마스크 없음) — 라이브 룸에 세그먼트 물리 복원 시 별도 parity 필요.

# 7차 회귀 (live → AI sim 정렬)

- `BilliardBallMotor`에서 `TableCushionSegment` 스캔 제거, `physics_cushion_lock` 제거, cloth bounds만 쿠션 집계.
- PlayMode `BilliardLiveParityTests`가 harness/sim 서명(312°/15 → 6쿠션)을 live PASS 기준으로 사용.
- GM 원본: `scr_physics.gml` `physics_resolve_table_bounds` + lock, `physics_resolve_cushion_collision`, `obj_ball_player` Collision_obj_cushion(플레이어 쿠션 가산)과 **불일치**.

증거: `docs/devlog/2026-11-03-unity-port/before/live-parity-reference.md`

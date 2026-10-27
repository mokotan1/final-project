# 바텐더 브레이크 분산 개선 (2026-10-27)

## 문제와 수정 전 기록

- `before/user-reported-cluster.png`는 사용자가 제공한 브레이크 이후 화면이다. 대상구와 다른 공이 중앙에 모여 보인다.
- `before/bartender-break-existing.mp4`는 기존 파워 15~18, 정면 기준 ±4° 바텐더 브레이크의 이전 Runner 기록이다.
- 기존 AI 브레이크 파워 15~18은 플레이어 일반 샷 최대 파워 18과 같은 수준이었다. 프로젝트에는 `randomize()` 호출도 없어서 새 실행마다 같은 난수 순서로 브레이크가 반복됐다. 실제로 난수 초기화 전 `after/trial-1`~`trial-3`의 공 배치가 거의 같았다.

## 변경

- `scripts/scr_story_ai/scr_story_ai.gml`의 **스토리 바텐더 브레이크에만** `randomize()`를 호출한다.
- 같은 브레이크의 파워를 **26~30**으로 올리고, 타깃 중심에서 좌우 **5~6°** 비껴 조준한다. 정면에 가까운 타격을 피하면서 매 시작의 충돌 방향을 바꾼다.
- 마찰·반발계수, 일반 AI 샷, 플레이어 샷, 점수·50합 규칙은 수정하지 않았다.

## 변경 후 검증

- `after/angled-1`~`angled-4`에 동일한 경기 방·화면 크기에서 네 번 촬영한 스크린샷과 영상이 있다. Runner는 보조 모니터 DISPLAY2에 배치했다. 네 번의 공 배치가 서로 달랐고 이전 중앙 뭉침에 비해 넓게 분산됐다. 물리 충돌 결과이므로 일부 공이 가까이 멈출 가능성까지 제거한 것은 아니다.
- `tools/story_break_runtime_harness.gml`의 실제 Runner 실행 결과: `PASS bartender-break-10,0-pair-handoff,break-foul-suppress,power-26-30 (player override ignored)`.
- Igor VM 빌드: `Build/CushionChallenge-2026-10-27.win`, SHA256 `FBDDC2B97F4501CDAE581EFF3A2624FFB1B256AFBE14F23AE0210068D8B2A83D`.
- `after/randomized-1`~`randomized-3`은 난수 초기화 효과를 확인한 중간 단계 캡처다. `after/angled-*`가 최종 구현이다.

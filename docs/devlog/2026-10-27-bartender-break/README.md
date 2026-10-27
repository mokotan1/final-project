# 바텐더 브레이크 고정 (2026-10-27)

사용자 요청으로 스토리 50합 경기의 브레이크 선공을 바텐더로 고정했다. 앞선 50:50 선공 결정은 이 변경으로 대체된다.

## 비포·애프터

- 변경 전 플레이어 브레이크 영상과 초기 화면은 `before/`에 보관했다. 2026-10-26 검증 캡처에서 복사한 자료이며, 당시 플레이어 선공은 테스트 주입 상태였다.
- 변경 후 `after/bartender-direct/story-flow.mp4`와 프레임은 같은 스토리 경기 로직을 실행한다. 테스트 빌드는 도입 화면을 건너뛰고 경기 방에 진입하지만 선공을 강제로 주입하지 않는다. `frame_0100.png`에 `브레이크 · 바텐더 차례`가 표시되고, 이후 바텐더가 브레이크한다. 보조 모니터 DISPLAY2에서 촬영했다.
- `after/` 루트의 캡처는 정식 게임 진입 경로였으나 도입 화면에서 진행되지 않아 브레이크 증거로 사용하지 않는다.

## 변경과 검증

- `scripts/scr_story_versus/scr_story_versus.gml`: 선공 선택 함수가 항상 `STORY_TURN_AI`를 반환한다. 브레이크 파울 억제, AI 조준·파워, 점수·50합 규칙은 유지한다.
- `tools/story_break_runtime_harness.gml`: 10번 재시작해 전부 바텐더 선공이고 브레이크 종료 후 0합·손님 턴인지 확인했다. 옛 플레이어 강제 변수도 무시됨을 확인했다. Runner 결과: `PASS bartender-break-10,0-pair-handoff,break-foul-suppress (player override ignored)`.
- `python tools/test_story_versus.py`, `python tools/validate_project.py` 통과. Igor VM 정식 빌드 및 Runner 촬영 성공.
- 정식 빌드: `Build/CushionChallenge-2026-10-27.win`, SHA256 `B3B2500C62C27959E5ECE46805932BC83D4E292C24095C0E6F46E5B8E1E22AD7`.

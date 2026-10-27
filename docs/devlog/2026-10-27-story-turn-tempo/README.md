# 스토리 바텐더 대사·턴 템포 개선 (2026-10-27)

## 기준과 변경

- 기획서: https://docs.google.com/document/d/1NtR0oEYix1ETj-tZ16G6O3I1B17HD1dU1FK29iMCxwg/edit
- 공이 멈춘 뒤 반응 대사 4초를 기다리고 턴 배너 1.2초를 보여 주던 흐름을 변경했다. 이제 반응 대사를 오버레이로 유지하면서 턴 배너는 0.5초 뒤 종료된다. AI 턴은 추가 0.5초 후 샷을 시작한다. 따라서 코드상 대기 시간은 플레이어 약 0.5초, AI 약 1초다. 이는 공이 멈춘 뒤의 턴 연출 시간이며 실제 샷 애니메이션 시간은 포함하지 않는다.
- 첫 50합 규칙 설명·브레이커 안내와 스테이지 클리어 확인은 기존처럼 입력을 막는다. H 도움말과 샷 반응 대사는 턴 입력을 막지 않는다.
- 빠르게 연속 샷이 나와도 반응 대사가 덮어써지지 않도록 큐에 넣었다. 도움말이 보이는 동안 반응 대사의 남은 표시 시간은 일시 정지된다. 스테이지 전환과 최종 결과에서는 지난 반응 대사를 비운다.
- 배너 페이드 시간을 짧아진 배너에 맞췄고, 기회 소진 메시지를 대사·배너와 떨어진 위치로 옮겼다. 물리, 점수, 위험샷, 브레이크 절차는 변경하지 않았다.

## 비포·애프터

- `before/story-flow.mp4`, `before/frames/`: 수정 전 Runner 촬영. 샷 이후 반응 대사가 턴 전환을 기다리게 하는 장면.
- `after-final/story-flow.mp4`, `after-final/frames/`: 수정 후 같은 스토리 모드·1280×720 화면·플레이어 샷 입력으로 촬영. `frame_0240.png`에서 바텐더 대사와 AI 턴 표시가 함께 보이고, `frame_0250.png`에서 대사가 남아 있는 동안 AI 샷의 파울 판정이 나타난다.
- 촬영은 두 번째 모니터(DISPLAY2)에서 수행했다. 브레이크의 랜덤 요소 때문에 공 위치는 두 촬영에서 완전히 동일하지 않다. `after/`는 반응 큐 보완 전 중간 촬영본이며 최종 비교는 `after-final/`을 사용한다.

## 검증

- 턴 템포 Runner 하네스: `PASS opening,breaker,overlay,stage-clear,banner-0.5s,ai-0.5s,help,reaction-queue,ai-shot`.
- 50합 Runner 회귀 하네스: 5개 결과 케이스 및 규칙·위험샷·점수 상한·AI·브레이크·결과 데이터 검사 통과.
- `tools/test_story_fifty_round.py`, `tools/test_story_versus.py`, `tools/test_game_mode_rules.py`, `tools/validate_project.py`, `tools/validate_presentation_resources.py` 통과.
- Igor VM 배포 빌드 성공: `D:\final_project\Build\CushionChallenge-2026-10-27.win` (SHA-256 `C3E7D6054AC9D028D5421A675084BA0B5AD6BCE8196047095DA9F97818D3F36F`).

## 이번 작업의 소스 파일

- `scripts/scr_story_versus/scr_story_versus.gml`
- `objects/obj_story_versus_game/Step_0.gml`
- `scripts/scr_story_ai/scr_story_ai.gml`
- `tools/story_turn_tempo_harness.gml`, `tools/build_story_tempo_harness.ps1`
- `tools/story_50_runtime_harness.gml` (반응 큐를 고려한 검증 기대값)

## 남은 확인

- 장시간 실제 플레이에서 반응 대사가 누적되는 정도와 읽기 편한 속도는 추가 플레이 테스트로 조정할 수 있다. 큐는 각 대사를 보존하며 스테이지 전환과 결과에서 초기화한다.

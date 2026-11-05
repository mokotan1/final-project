# 스토리 밸런스·바텐더 상황 아이템 (2026-10-27)

파울 제거의 턴 종료 복원은 후속 수정인 `docs/devlog/2026-10-27-foul-ball-turn-restore/README.md`를 따른다.

기획 기준: [스토리 밸런스·바텐더 상황 아이템 기획서](https://docs.google.com/document/d/1Y7fdNOkxgzdCU4EVHCXd7BFVzOh4M3N59nTFejmJVOQ/edit).

## 작업 전

- `before/story-initial.png`, `before/story-flow.mp4`, `before/story-final.png`은 수정 전 보관 빌드 `Build/CushionChallenge-2026-10-27.win`(SHA-256 `C3E7D6054AC9D028D5421A675084BA0B5AD6BCE8196047095DA9F97818D3F36F`)을 출력 폴더에 복사해 GameMaker Runner에서 1280×720으로 촬영했다.
- 기존 코드는 아이템 구매를 손님 턴에만 허용하고, 파울 제거가 한 개에만 적용되며, soft 조기 종료 손님 리드를 1,500점으로 판단했다.
- 첫 촬영은 Runner에 상대 경로를 넘겨 오류 창이 나와 비교 자료가 될 수 없었다. 절대 경로로 다시 촬영하여 위 파일을 교체했다. 자동 START 클릭이 누락되어 모드 메뉴에 머문 촬영도 버리고, 최종 자료가 경기 화면인지 확인했다.

## 작업 후

- `after/story-initial.png`, `after/story-flow.mp4`, `after/story-final.png`은 수정 후 VM 빌드(SHA-256 `5DA45597F5CC5CC909901CDC923F1198B31E552310761E557D908E2C27811097`)를 같은 출력 폴더에서 실행해 촬영했다. 양쪽 모두 360프레임, 180프레임째 같은 플레이어 샷 입력이다. 브레이크 난수 때문에 공의 최종 위치는 다르다.
- 손님과 바텐더의 아이템 구매를 공통 처리하고, 턴당 한 개로 제한했다. 파울 제거는 구매 직후 존재하는 파울공 전부에 적용하며 0개일 때 구매되지 않는다. 바텐더는 normal/all-out에서 보드·점수차에 따라 아이템을 선택한다.
- soft 조기 종료 및 all-out 강제 리드는 10,000점, 적극 유틸 사용 리드는 5,000점, 접전 대사 차이는 2,000점, 바텐더 위험 샷 허용 리드는 100,000점이다. 손님의 예약 위험 샷과 바텐더의 위험 샷은 분리한다.
- 도움말·상점 설명·로컬 대사 JSON/CSV의 변경된 규칙 문구를 동기화했다.

## 검증

- GameMaker Igor VM 컴파일 성공. 정식 빌드를 Runner에서 실행해 전후 경기 화면과 샷 흐름을 촬영했다.
- `tools/story_50_runtime_harness.gml` Runner 결과: PASS. 양측 구매 비용, 파울공 전부 제거, 이후 새 파울공 유지, 한 턴 한 개, 0개 구매 거부, soft 아이템 미사용, normal 자동 공 이동, 위험 샷 100,000점 경계·손님 상태 보존, 50합 승·패·무승부와 결과 데이터를 검사했다.
- `python tools/test_story_versus.py`, `tools/test_story_fifty_round.py`, `tools/test_story_reaction_copy.py`, `tools/validate_project.py`, `tools/validate_galmuri_font.py` 통과.
- 실제 물리 자동 플레이를 검증 전용 600 FPS로 가속해 50합을 완료했다(`after/ai_metrics.csv`, `after/autoplay_result.txt`). 한 플레이에서 AI의 합당 점수 증가 평균은 1~10합 400점, 40~50합 약 2,618점으로 후반이 높았다. 최종 50합, 손님 4,700점·바텐더 110,400점. AI 아이템 사용은 공 이동 0회·위험 샷 0회·파울 제거 1회였고 파울공 2개가 제거됐다. 100,000점 미만 위험 샷 사용은 0회였다. 이는 한 번의 난수 결과이며 아이템 빈도와 체감 난이도의 충분한 표본은 아니다.

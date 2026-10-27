# 스토리 50합 경기 변경 기록

## 변경 전 (2026-10-22)

- 현재 소스를 GameMaker Igor VM으로 컴파일해 `Build/story_50_before.win`에 보존했다. SHA256: `BD93FD8E565267164D7B1D4E1131A48DD10BCE8C8E195323EEFFE74B8B72E41D`.
- 실제 Runner를 1280×720으로 실행해 `before/baseline/`에 메뉴, 모드 선택, 오프닝, 스토리 시작 화면과 36초 분량의 `story-flow.mp4`를 촬영했다. 자동 입력은 스토리 메뉴 진입과 18초 시점의 손님 샷 시도다.
- `story-initial.png`에서 이전 저장 기록이 적용되어 `1-2 벽의 값`, 손님 400점, 기회 3/3, 목표 500점이 보인다. `frames/frame_0100.png`에서는 바텐더 브레이크 뒤 손님 차례가 보인다.
- `story-final.png`는 검게 촬영되었다. 이 화면만으로 실제 결과 화면 또는 메뉴 이동 여부를 판정하지 않는다. 영상과 중간 프레임을 함께 참고한다.

## 변경 후

- 최종 소스를 Igor VM으로 다시 컴파일했다. `Build/story_50_release.win` SHA256: `195549B2174430973797063B8246C6C28A8CA8ECFD8B46922997DBC10869766B`. `Build/final_project.win`도 같은 빌드로 복원했다.
- `after/production/story-flow.mp4`는 변경 전과 같은 메뉴 진입·18초 시점 샷 시도로 촬영한 36초 비교 영상이다. 최종 검토와 수정 뒤 `after/final-reviewed/`를 정식 빌드로 다시 촬영했다. 촬영 도구는 창 제목 표시줄을 제외한 1280×720 클라이언트 영역을 저장한다. 변경 전 영상에는 제목 표시줄이 포함되고 화면 아래 약 30픽셀이 잘려 있다.
- 변경 전 HUD는 저장된 `1-2 벽의 값`, 손님 400점, 기회 3/3, 목표 500점을 표시했다. 변경 후 `after/final-reviewed/story-initial.png`는 이전 저장값과 무관하게 브레이크 0합·양쪽 0점을 표시한다. `after/final-reviewed/frames/frame_0224.png`에서는 브레이크 100점이 바텐더 점수로 반영되고 현재 합이 `1/50`이다. `story-final.png`는 촬영 종료 직전 검은 화면이므로 결과 판정 자료로 사용하지 않는다. `after/production/frames/frame_0359.png`에서는 손님 800점·바텐더 500점인데도 경기가 `2/50`으로 진행 중이다.
- 테스트 전용 GML 하네스를 실제 Runner에서 실행했다. `after/story50-runtime-test.txt`의 `PASS`는 0합 브레이크와 브레이크 패스, 50합 손님·바텐더 차례 경계, 5합 테스트 설정, 승·패·무승부 결과와 대사 ID, 점수 상한, 위험 샷 0/1/2/6/7쿠션, AI 난이도 구간, GENTLE 최대 2회를 검사한 결과다. 하네스는 빌드 직후 원래 소스로 복원된다.
- `after/story50-autoplay-result-final.txt`는 최종 검토와 수정 뒤 테스트 전용 자동 입력으로 **실제 공 이동과 AI 샷을 거쳐 50합을 완주**한 기록이다: 손님 4,000점, 바텐더 65,500점, 바텐더 승리. 자동 입력은 손님 공을 목표 공 방향으로 쳤고 대사·배너 대기만 생략했다. 따라서 이 기록은 50합 물리 진행을 검증하며, 수동 조작의 모든 경우나 밸런스 품질을 증명하지는 않는다. 이전 실행 기록은 `after/story50-autoplay-result.txt`에 남겼다.
- `after/visual-test-client/story-initial.png`는 테스트 전용 상태 설정으로 양쪽 점수 999,999,999와 무승부를 표시한 1280×720 화면이다. 9자리 점수와 결과 문구가 잘리지 않는다. `after/visual-result-return/result-return.png`는 결과 화면에서 클릭 후 메뉴로 이동한 실제 Runner 화면이다. 이 두 자료는 일반 플레이 화면이 아니라 명시된 테스트 상태다.
- `tools/test_story_fifty_round.py`, `tools/test_story_versus.py`, `tools/test_story_reaction_copy.py`, `tools/test_first_story_launch.py`, `tools/validate_korean_font.py`, `tools/validate_project.py` 통과. 한글 폰트는 새 대사에 필요한 457개 글리프로 갱신했다. 최종 Igor VM 컴파일도 통과했다.

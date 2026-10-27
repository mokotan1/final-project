# 스토리 상점 UI와 상대 AI

## 작업 전

- 2026-10-19, 기존 `Build/verify_project.win`을 `tools/capture_story_ai.ps1`로 실행하여 스토리 AI 검증 룸의 1280×720 화면과 영상을 촬영하려 했다.
- 제한된 실행 환경에서 Windows `{잘못된 DLL 재할당}` 오류가 발생하여 게임 창이 열리지 않았다.
- 일반 데스크톱 권한으로 재시도했으나 자동 승인 검토가 용량 오류로 완료되지 않아 명령이 실행되지 않았다. 따라서 이번 작업의 `before/`에 실제 촬영 자료는 없다.

## 작업 후

- 스토리 경기에서 엔드리스 모드 인벤토리와 같은 슬롯·아이콘을 화면 하단에 표시하고, 각 슬롯 안에 점수 가격을 적었다. 클릭 영역도 슬롯 위치와 일치시켰다. 아이템 사용 시 기존 스토리 점수에서 가격이 차감된다.
- 바텐더 AI는 엄격한 득점 후보가 없더라도 점수와 파울 위험을 비교한 대체 샷을 골라 실제 타격한다. AI 턴과 공 정지 상태를 재확인하고, 손님이 구매한 위험 샷 상태를 보존한다.
- `tools/test_story_versus.py`, `tools/story_ai_fixture_sim.py`, `tools/validate_project.py`를 통과했다. GameMaker Igor VM 컴파일도 통과했다.
- 새 `Build/final_project.win`으로 `tools/capture_startup.ps1`을 실행해 작업 후 게임 화면을 촬영하려 했으나, 작업 전과 같은 Windows `{잘못된 DLL 재할당}` 오류로 Runner 창이 열리지 않았다. `after/`에 실제 게임 스크린샷이나 영상은 없다. 상점 클릭·가격 표시와 실제 AI 샷은 이번 빌드의 런타임에서 확인되지 않았다.

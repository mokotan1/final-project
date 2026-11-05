# Unity 좌표 이식 — 2026-11-05

## 작업 전 직접 확인

- [GMS 엔드리스](before/gms-attempt/story-initial.png)는 현재 GMS 빌드를 Runner에서 1280×720으로 촬영했다. 배치 대기 상태이며 플레이어·목표·파울 공이 보인다.
- [Unity 엔드리스](before/unity-endless-partial.png)는 수정 전 실제 Unity Game View 캡처다. 출력 PNG는 1280×720이나 `Screen.width/height`로 읽은 1083×523은 포커스에 따라 다른 뷰를 나타낼 수 있어 실제 Game View 렌더 크기는 확인되지 않았다. 따라서 전체 화면의 정확한 비교 자료로 삼지 않는다. 공 다섯 개가 보인다.
- 두 게임은 같은 엔드리스 모드지만 GMS의 무작위 배치와 Unity의 고정 스토리형 배치가 달라 같은 공 배치 비교가 아니다. 원본 일반 모드는 AI 공을 만들지 않는다는 사실은 `scr_application_commands.gml`에서 확인했다.
- 움직임 촬영을 시도했으나 Unity는 GMS 촬영 후 창이 최소화되어 입력이 거부됐고, 연속 캡처는 동일한 프레임이었다. GMS 자동 드래그 영상도 샷 성공을 확인하지 못했다. 따라서 해당 영상들은 동작 비교 증거가 아니다.
- `rm_game.yy`의 당구대 배경은 (160,90), 원본 룸은 1280×720이다. 스토리 일반 배치와 인트로 랙은 `story_versus_spawn_layout`에서 직접 확인했다.

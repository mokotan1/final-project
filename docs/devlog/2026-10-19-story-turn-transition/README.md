# 스토리 턴 전환 안내

## 작업 전

- `before/story-turn-before.png`와 `before/story-turn-before.mp4`는 사용자가 직접 실행한 Runner의 스토리 화면·영상 사본이다. HUD의 차례 문구는 즉시 바뀌지만, 샷 사이에 턴이 넘어갔다는 별도 연출은 없다.

## 작업 후

- 스토리 경기 시작과 손님·바텐더 턴 교체 때 차례 안내 배너를 표시한다. 시작 대사와 샷 반응이 끝난 뒤 배너가 약 1.2초 나타나고, 그동안 두 쪽 모두 타격하지 못한다. AI는 배너 뒤 1초를 더 기다리고 샷을 실행한다.
- 내부 AI 검증 모드의 기존 턴 흐름은 유지한다.
- `tools/test_story_versus.py`, `tools/validate_project.py`와 GameMaker Igor VM 컴파일을 통과했다. 실제 경기 영상 확인은 진행 중이다.

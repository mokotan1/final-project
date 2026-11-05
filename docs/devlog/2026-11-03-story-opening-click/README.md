# 스토리 초기 설명 클릭으로 넘기기 (2026-11-03)

## 변경
- 스토리 50합의 규칙 설명과 브레이커 안내가 표시되는 동안 클릭 또는 Enter로 현재 문장을 넘긴다. 자동 진행 타이머는 유지한다.
- 기존 대사 클릭 소비 처리를 사용해 클릭이 같은 프레임의 샷 입력에 전달되지 않도록 했다. 초기 설명에는 클릭 / ENTER 안내를 표시한다.

## 전후 촬영
- `before/click-frame.png`, `before/click-flow.mp4`: 기존 빌드에서 같은 클릭과 드래그 입력을 적용. 클릭 직후에도 첫 번째 문장이 남아 있다.
- `after/frames/frame_0008.png`, `after/story-flow.mp4`: 변경 빌드에서 같은 입력을 적용. 클릭 후 두 번째 문장이 보인다.
- 두 영상 모두 같은 스토리 모드와 1280×720 클라이언트에서 촬영했으나 보조 모니터 폭이 1080px라 오른쪽이 검게 잘렸다. 이 촬영에서 클릭 안내 문구 전체는 확인할 수 없다.

## 검증
- Runner 하네스로 세 규칙 문장과 브레이커 안내를 순서대로 넘기고 턴 잠금과 기존 반응 큐를 검사했다. 변경 전 `opening-rule-not-skippable`, `opening-next-rule` 실패를 재현했고 변경 후 PASS를 확인했다. 기존 하네스의 반응 시간 기대값은 현재 대사 길이 기반 시간에 맞췄다.
- GameMaker VM 컴파일, `test_story_versus.py`, `test_story_fifty_round.py`, `validate_project.py`, `validate_galmuri_font.py` 통과.
- 실제 Runner 클릭 촬영은 첫 문장에서 두 번째 문장으로의 전환을 확인한다. Enter 입력과 나머지 클릭 단계는 Runner 하네스에서 대사 진행 함수를 검증했으며 실제 키 입력 촬영은 하지 않았다.

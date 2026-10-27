# 파워 글자와 게이지 간격 (2026-10-27)

- 수정 전: 엔드리스 HUD의 파워 게이지는 y=42~58에 그려졌다. `before/endless/story-initial.png`와 `story-flow.mp4`는 1280×720 Runner 화면이다.
- 수정 후: 글자는 그대로 두고 게이지의 배경과 채움 막대를 모두 y=50~66으로 8px 내렸다. 글자 아래 여백은 약 10px이다. 엔드리스와 스토리 HUD에 동일하게 적용했다. `after/endless/story-initial.png`와 `story-flow.mp4`는 같은 모드·화면 크기의 Runner 촬영이다.
- Igor VM 컴파일 통과 (`compile.log`). 빌드 파일은 `Build/final_project.win`이다. 엔드리스 화면을 실제 Runner에서 확인했다. 스토리 HUD는 같은 좌표를 사용하지만 별도 Runner 촬영은 하지 않았다.

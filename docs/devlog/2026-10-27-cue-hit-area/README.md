# 큐대 클릭 범위 개선 (2026-10-27)

## 변경 전

- `obj_cue`는 공 중심에서 56px 이내를 누를 때만 드래그를 시작했다. `spr_cue`의 실제 불투명 픽셀은 로컬 x=2~217, y=4~11이고, 화면에서는 공에서 28px 떨어진 지점부터 그려진다. 따라서 보이는 큐 몸통 대부분은 클릭할 수 없었다.
- 수정 전 빌드 `output/final_project/final_project.win`을 Runner에서 실행해 `before/cue-test/`에 촬영했다. 엔드리스에서 공을 (380, 350)에 놓고 큐 몸통 (520, 350)을 누른 후 (180, 350)까지 드래그했다. `story-initial.png`와 `frames/frame_0020.png`에서 공이 (388, 350) 근처에 그대로 있다.

## 변경 후

- 클릭 시작 판정을 큐 스프라이트의 회전한 길이·두께에 맞췄다. 양 끝과 옆면에 최대 약 6px 여유를 두었다. 샷 파워·방향 계산과 물리는 그대로다.
- 같은 입력을 수정 후 빌드 `Build/final_project.win`에서 실행해 `after/cue-test/`에 촬영했다. `frames/frame_0030.png`에서 공이 오른쪽으로 이동하고 큐가 다음 위치를 따라가며, 몸통 클릭으로 샷이 시작됐음을 확인했다.
- 일반 화면의 수정 전후는 `before/story-flow.mp4`, `after/story-flow.mp4`에 있다. 이 영상들은 공 배치 전 화면이므로 클릭 검증에는 `cue-test` 자료를 사용한다.
- `capture_story_flow.ps1`에 공 배치와 샷 시작 좌표 옵션을 추가해 같은 입력을 재현했다. 두 촬영에서 `PrintWindow`가 간헐적으로 검은 프레임을 저장했으므로 검은 프레임은 판정 근거로 사용하지 않았다.

## 검증

- GameMaker Igor VM 컴파일 통과 (`compile.log`). 실제 출력 파일은 로그의 `Build/final_project.win`이다.
- `python tools/validate_project.py` 통과 (75개 리소스).
- 큐 스프라이트의 다른 각도에서도 동일한 회전 좌표식을 적용한다. 별도 각도별 Runner 입력 검증은 아직 하지 않았다.

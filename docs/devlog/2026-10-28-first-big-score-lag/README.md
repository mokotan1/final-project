# 첫 고득점 프레임 지연 개선 (2026-10-28)

## 수정 전 재현

- `tools/build_big_score_probe.ps1`는 정식 소스를 복원하는 임시 빌드 주입으로 스토리 50합 방에 100,000점 `score_gain_fx`를 표시하고, 새 글꼴 생성 시간과 프레임 간격을 Runner 로그에 남긴다. 실제 점수·저장 파일은 바꾸지 않는다.
- `before/story-initial.png`, `before/story-flow.mp4`는 이 테스트 상태를 1280×720, 120프레임으로 촬영한 자료다.
- `before/probe_stdout.txt`: 고득점 숫자 확대 비율이 매 프레임 달라지면서 31~42px 글꼴을 차례로 `font_add`했다. 각 생성에 약 173~177ms가 걸렸다. 효과 시작 4~25프레임 22개 중 11개가 50ms를 넘었고, 최대 178.77ms·평균 88.87ms였다.
- 원인: `objects/obj_ui/Draw_64.gml`의 고득점 숫자 확대 비율이 `pixel_draw_text_transformed`의 글꼴 크기 선택에 직접 쓰였다. 같은 문구를 그리면서도 프레임마다 새 글꼴 리소스를 만들었다.

## 수정

- 고득점 숫자는 고정 33px 글꼴을 사용하고 화면 확대 비율만 변하게 했다. 제목과 총점은 기존 11px 글꼴을 재사용한다.
- 11px·33px 글꼴은 `obj_ui` Create에서 경기 화면 준비 중 한 번 생성한다. 다른 화면의 텍스트 호출은 기존 크기 선택 방식을 유지한다.

## 수정 후 기록과 확인

- `after/story-initial.png`, `after/story-flow.mp4`는 같은 테스트 상태·화면 크기·120프레임 촬영이다.
- `after/probe_stdout.txt`: 같은 4~25프레임 22개 중 50ms 초과 0개, 최대 16.41ms·평균 16.19ms. `tools/test_big_score_probe.ps1`의 수정 전 실패/수정 후 통과를 확인했다.
- `python tools/validate_project.py`에서 76개 리소스 검사가 통과했고, Igor VM 정식 빌드가 성공했다. 실행 파일은 `Build/CushionChallenge-2026-10-28-score-smooth.win`, 빌드 로그는 `compile.log`다.
- 측정은 동일 PC의 주입한 고득점 상태에 한정된다. 실제 플레이의 첫 고득점 및 다른 PC의 글꼴 생성 시간은 사용자가 확인할 수 있다. 글꼴 생성 비용은 경기 방 진입 시점으로 이동했다.

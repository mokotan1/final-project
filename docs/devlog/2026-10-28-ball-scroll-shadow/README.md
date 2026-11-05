# 공 텍스처 스크롤·그림자 (2026-10-28)

기획 기준: [공 텍스처 스크롤 셰이더 기획서](https://docs.google.com/document/d/1Y5xHNEKtIv0F3vVJSZmmpVfA7Qwi0d0KdO8z6Ihkyhg/edit).

## 작업 전

- `before/story-initial.png`, `before/story-final.png`, `before/story-flow.mp4`: 수정 전 `Build/CushionChallenge-2026-10-28.win`을 GameMaker Runner의 스토리 50합 경기, 1280×720 화면에서 촬영했다. 240프레임이며 180프레임째 동일한 플레이어 샷 입력을 보냈다.
- 현재 공통 `obj_ball`은 물리 이동과 별도로 공 종류별 고정 스프라이트를 그리며, 그림자가 없다. 공 반지름은 물리 설정에서 16px이다.

## 작업 후

- `objects/obj_ball/Create_0.gml`과 `Step_0.gml`: 공마다 스크롤 좌표와 강도를 보관하고, 매 Step의 `hspeed`·`vspeed`를 둘레 `2πr`로 나눠 누적한다. 정지하면 좌표가 유지된다.
- `objects/obj_ball/Draw_0.gml`: 공보다 먼저 세 겹의 반투명 타원 그림자를 그린다. 플레이어·목적구·파울공·AI 공 모두 공통 Draw를 사용한다.
- `shaders/sh_ball_scroll/`: 원형 알파와 외곽선은 고정하고, 스프라이트 셀 내부의 색 무늬만 UV로 이동한다. 별도 검토에서 발견한 외곽선 이동과 원본 무늬 잔상 문제를 수정했다. AI 공의 기존 색조도 유지한다.
- `after/story-initial.png`, `after/story-final.png`, `after/story-flow.mp4`: 수정 후 빌드를 같은 스토리 50합 경기와 1280×720 화면에서 240프레임 촬영하고 180프레임째 같은 입력을 보냈다. 브레이크 난수로 공 배치와 득점 장면은 다르다.
- Igor VM 빌드 성공. 실행 파일은 `Build/CushionChallenge-2026-10-28-ball-scroll.win`, 로그는 `compile.log`에 있다. 구현 에이전트의 초기 프로젝트 리소스 검사에서는 76개 리소스가 확인됐다.
- 이번 촬영은 짧은 스토리 경기 구간의 시각 자료다. 강도 0 비교, 벽 반사와 모든 게임 모드의 장시간 프레임 성능은 사용자가 직접 확인하기로 한 플레이 검증 범위에 남겨 둔다.

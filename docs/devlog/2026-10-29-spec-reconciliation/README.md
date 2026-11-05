# 기획서와 현행 코드 대조 (2026-10-29)

## 기준과 작업 전

- [기획서·코드 대조 페이지](https://cushion-challenge-vs-2026-10-29-nv6c.pages.grok.bot/)의 불일치·미구현 항목을 최신 코드와 원문 기획서 5개로 재확인했다.
- `before/menu.png`, `before/story-initial.png`, `before/story-final.png`, `before/story-flow.mp4`: 수정 전 정식 빌드의 50합 경기, 1280×720, 240프레임, 180프레임째 손님 샷 입력 기록.
- 5-b의 복구 A/B 및 9,600점 보정은 이후 사용자가 정한 10만 점 차 위험 샷 방식으로 대체됐다. 첫 10합 soft의 2,000점 기준, AI ±2,000점 목표, AI 아이템 세부 임계, 3겹 공 그림자도 현행 결정이다.

## 변경

- 턴 중 일반 대사·반응 대사를 클릭 또는 Enter로 넘긴다. 첫 규칙 설명과 브레이크 배정 대사의 입력 잠금은 유지한다.
- 반응 대사의 표시 시간을 글자 수에 따라 2~4초로 제한한다. 결과·스테이지 완료 시간은 변경하지 않았다.
- 대사 넘기기 클릭과 상점 아이템 클릭이 같은 프레임의 큐 드래그 시작으로 이어지지 않도록 큐 입력을 차단한다.
- 밸런스·턴 템포·공 셰이더 Google Docs에 2026-10-29 현행 결정을 추가했다. 선택 항목인 `scroll_y × 0.75`는 플레이 근거 없이 적용하지 않았다.
- Galmuri11 한글은 현재 Runner 화면에서 표시된다. 오래된 폰트 리소스가 남아 있으나 런타임 GML 참조가 없어 이 작업에서 제거하지 않았다.

## 작업 후와 검증

- `after/menu.png`, `after/story-initial.png`, `after/story-final.png`, `after/story-flow.mp4`: 같은 모드·해상도·프레임 수·입력 절차로 촬영. 난수 때문에 공 배치는 다르다.
- `tools/story_50_runtime_harness.gml`에서 오프닝 규칙 대사 스킵 금지, 반응 대사 2초 하한, 반응 대사 스킵을 실제 GML Runner로 확인했다. `STORY50_RUNTIME_TEST PASS`.
- `python tools/test_story_versus.py`, `python tools/validate_project.py`, Igor VM 빌드가 통과했다. 정식 실행 파일은 `Build/CushionChallenge-2026-10-29-spec-reconcile.win`이다.
- 하네스 빌드가 `Build/final_project.win`을 일시적으로 덮는 위험을 독립 검토에서 확인했다. 최종 정식 빌드를 다시 수행해 두 실행 파일의 SHA-256이 같음을 확인했고, `after-default-build/menu.png`에서 기본 실행 파일의 메인 메뉴 시작을 확인했다.
- 영상에는 10만 점 격차 이벤트나 상점 아래 공 배치가 없어 해당 상황의 실제 입력 비교는 담기지 않았다. 사용자가 직접 플레이 검증을 맡기로 한 영역이다.
- 전후 영상은 대사 스킵 입력과 상점·큐 중첩 클릭을 직접 재현하지 않는다. 대사 잠금·표시 시간·스킵은 GML 하네스로 확인했으며, 중첩 클릭의 실제 조작감은 추가 플레이 확인이 필요하다.

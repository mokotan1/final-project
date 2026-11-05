# Unity 메뉴 버튼 연결 (2026-11-04)

## 수정 전

- Unity MainMenu Play 모드의 1280×720 Game View: `before/menu.png`.
- Unity Pipeline에서 Story 버튼 `onClick.Invoke()`를 실행한 후에도 활성 씬은 `MainMenu`였다. 이는 실제 포인터 클릭이 아닌 버튼 이벤트 호출이다.
- Unity 플러그인으로 동등한 조작 영상을 아직 촬영하지 못했다. 실제 포인터 클릭 검증도 필요하다.

## 수정 후

- 저장된 메뉴 버튼에 런타임 콜백을 연결하고 설정 패널의 포인터 판정과 슬라이더 핸들을 구성했다.
- `after/menu.png`는 같은 메뉴의 Game View, `after/story.png`는 Story 버튼 이벤트 호출 후 GamePlay 화면이다. 버튼 호출 직후 프레임은 MainMenu였고 다음 확인에서 GamePlay로 전환됐다.
- Unity PlayMode 메뉴 테스트 5/5 PASS: 세 모드 전환, 설정 토글, 설정 UI raycast 및 슬라이더 값 변경. 실제 마우스 조작이나 전후 영상은 촬영하지 않았다.
- 독립 검토에서 레이캐스트 대상 포함과 슬라이더 이벤트 검사는 실제 포인터 드래그·닫기 전체 흐름의 증거가 아니라는 점을 확인했다.

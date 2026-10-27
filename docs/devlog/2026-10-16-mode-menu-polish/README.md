# 모드 선택 메뉴 캐릭터·버튼·말풍선 수정

## 작업 전

`before/user_screenshot.png`는 사용자가 제공한 현재 메뉴 화면이다. 캐릭터 스프라이트의 별도 책상이 배경 바 카운터와 겹치고, 기본 재생이 말하기 동작이어서 정지 화면에서도 계속 말하는 것처럼 보인다. 버튼은 테두리만 덧그려 상태를 표시하며, 설명 문구는 배경 위에 직접 놓여 있다.

코드 변경 전에 `tools/capture_startup.ps1`로 `Build/final_project.win`의 실행 화면을 촬영하려 했으나 Windows `{Illegal System DLL Relocation}` 오류로 `Runner.exe`가 시작되지 않았다. 따라서 `before/`에는 이번 작업에서 직접 촬영한 게임 스크린샷이나 영상이 없다. 사용자 제공 이미지를 실제 촬영물로 표시하지 않는다.

## 작업 후

`spr_assistant_bar_idle`의 투명한 상반신을 기존 바 상판에 맞춰 배치하고, 배경 카운터 전면을 다시 그려 하반신만 가렸다. 기본 모션은 눈뜸 60프레임 → 눈깜빡임 5프레임 → 눈뜸 96프레임을 반복한다. 기존의 불투명 배경과 별도 책상이 포함된 말하기 스프라이트는 이 화면에서 재생하지 않는다.

STORY·ENDLESS·CLASSIC·START는 기본/호버/선택(누름) 상태를 GML 픽셀 도형으로 각각 그린다. 선택한 모드는 누름 상태를 유지하며 START는 누른 그림을 6프레임 표시한 뒤 해당 모드로 이동한다. BACK 버튼은 화면과 클릭 판정에서 제거했고, Escape 키로 메인 메뉴에 돌아갈 수 있다. 모드 설명 말풍선도 별도 도형으로 그린다.

`after/layout_probe.png`는 처음 시도한 스프라이트 버튼·말풍선의 **이전 리소스 배치 미리보기**다. 현재 코드의 도형 버튼과 말풍선을 반영하지 않으며 실제 게임 화면도 아니다.

`after/idle_resource_preview.gif`도 이전 배치에 idle 3프레임을 1000/90/1600ms로 합성한 **리소스 애니메이션 미리보기**다. 실제 게임 실행 영상이나 현재 버튼 화면은 아니다.

## 검증

- `python tools/validate_project.py` 통과: 현재 73개 등록 리소스와 룸 참조 확인.
- `python tools/validate_modes.py` 및 `python tools/validate_presentation_resources.py` 통과.
- `python tools/validate_korean_font.py` 통과: 새 한국어 설명의 글리프 포함.
- 투명 idle 스프라이트의 루트·프레임·레이어 PNG 일치 확인. 버튼과 말풍선은 게임에서 스프라이트 텍스처를 사용하지 않는 것을 확인.
- 새 모드 설명 3개의 영어/한국어 텍스트 폭이 말풍선 안전 영역 520px 이내인 것을 확인.
- GameMaker Igor VM 컴파일 완료. 최종 도형 렌더링 빌드 로그: `after/igor_compile_procedural.log`.

## 사용자 실행 화면에서 발견한 문제와 수정

`before/user_broken_runtime.png`와 `before/user_broken_runtime_repeat.png`는 사용자가 제공한 두 차례의 실제 실행 화면으로, 버튼과 말풍선이 반복해서 노이즈로 보인다. 첫 화면 뒤 리소스 루트의 프레임 ID PNG 13개가 정상 `frames/` PNG와 다른 것을 발견해 복원했지만, 두 번째 실제 화면에서도 같은 렌더링 문제가 남았다. 따라서 PNG 복원과 컴파일 성공만으로 해결됐다는 이전 판단은 틀렸다.

두 화면 모두 새 버튼·말풍선 텍스처에서 문제가 나타났고, 배경·캐릭터는 정상 출력됐다. 문제 경로의 다섯 스프라이트를 프로젝트 등록과 Draw 코드에서 제외했다. 버튼·말풍선은 원래 GameMaker의 사각형·삼각형·픽셀 글꼴 렌더러로 그리도록 바꾸고, 실험용 PNG/메타데이터는 `datafiles/menu_mode_concept/experimental_sprite_imports/`에 보관했다. `python tools/validate_mode_menu_assets.py`는 문제가 된 텍스처가 다시 게임에 등록되거나 그려지지 않는지 확인한다.

작업 후에도 `tools/capture_startup.ps1`로 Runner 실행을 재시도했으나 Windows `{Illegal System DLL Relocation}` 오류가 반복되어 게임 창이 열리지 않았다. 따라서 실제 `after/` 게임 스크린샷·영상은 없고, 버튼 입력과 전환 및 실제 애니메이션 재생은 런타임에서 확인되지 않았다.

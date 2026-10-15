# 오프닝 야경·메뉴 비포·애프터

## 작업 내용
- 사용자 구도 스케치와 야경 참고 사진을 바탕으로, 오른쪽에 바 내부와 `OPEN` 간판이 보이는 도트 야경을 제작했다.
- 게임의 공·당구대 도트 밀도에 맞춰 320×180 논리 해상도를 4배 확대했다. 비점등 배경에는 약한 블러를 적용하고 별·창문·네온은 독립된 투명 레이어로 분리했다.
- GameMaker 메인 메뉴 배경에 연결하고 조명을 서로 다른 주기로 점멸시켰다.
- 기존 초록색 메뉴 판과 버튼 테두리를 제거하고 제목·부제·버튼을 글자로 그렸다.
- 실제 게임 화면에서 영문 `I` 뒤 간격과 글자 가독성 문제가 확인되어, 메인 메뉴 전용 좁은 글자 간격과 작은 그림자를 적용했다. 제목은 밤하늘, 버튼은 어두운 전경에 배치했고 클릭 영역을 함께 이동했다.

## 작업 전 자료
- `before/menu_background_source_before.png`, `before/menu_static_source_before.png`: 교체 전 프로젝트 스프라이트의 사본. 게임 화면 촬영은 아니다.
- `before/menu_panel_resource_composite_not_capture.png`: 초록색 메뉴 판을 제거하기 전 리소스 합성 이미지. 게임 화면 촬영은 아니다.
- `before/user_game_menu_text_only.png`: 사용자가 제공한 실제 게임 화면. 글자 간격과 겹침 문제를 고치기 직전 상태다.
- 초기 배경 교체 전 게임 실행은 샌드박스 안에서 Windows `{잘못된 DLL 재할당}` 오류로 실패하여 게임 스크린샷/영상이 없다.

## 작업 후 자료
- `after/menu_text_after_game.png`, `after/menu_text_after_game.mp4`: GameMaker Runner를 샌드박스 밖에서 실행해 1280×720 게임 클라이언트를 실제 촬영한 최종 화면과 6초 영상.
- `after/menu_resource_composite_not_capture.png`, `after/menu_resource_animation_not_capture.mp4`: 앞선 리소스 합성 시안. 게임 화면 촬영은 아니다.
- `after/menu_text_after_game_v1.png`: 최종 글자 간격·배치를 조정하기 전 중간 게임 캡처.

## 검증
- `python tools/validate_presentation_resources.py` 통과.
- GameMaker Igor VM 컴파일 통과. 실제 Runner 캡처로 제목·버튼 배치와 네온 표시를 확인했다.
- `python tools/validate_project.py`는 이번 메뉴 변경 후 재실행 시 별도의 `objects/obj_ball/obj_ball.yy` 충돌 이벤트에 `collisionObjectId`가 없어 `KeyError`로 중단했다. 메뉴를 수정하기 전에는 통과했으며, 해당 오브젝트는 이 작업에서 수정하지 않았다.

## 리소스
- `datafiles/opening_night_city/`에 생성 원본, 도트 배경, 별·창문·네온 레이어, 합성 미리보기가 있다. 이미지 생성은 내장 image_gen 도구를 사용했다.
- 실제 메뉴가 사용하는 스프라이트는 `spr_menu_background`, `spr_menu_stars_glow`, `spr_menu_windows_glow`, `spr_menu_neon_glow`다.

- 최종 검토에서 부제가 옥상 빨간 불빛에 가까운 점을 확인해 영문 문구를 "RISK. REWARD. ANGLES."로 줄이고 밝기를 높였다. 최종 스크린샷과 영상은 이 조정 후 다시 게임에서 촬영했다.

# 엔드리스 위험샷 점수 상한 (2026-10-26)

## 변경 전

- `rules_on_target_hit`은 위험샷 `100 × 10^쿠션`, 일반 샷 `100 × 2^쿠션`을 계산하고 `rules_on_shot_ended`가 제한 없이 `global.score`에 가산했다. 스토리는 별도 `story_versus_*` 분기로 들어가며 이 경로를 사용하지 않는다. 클래식은 같은 가산 경로를 사용한다.
- Runner 테스트 전용 GML 하네스가 엔드리스 점수를 **999,999,000**으로 놓고 실제 `rules_on_shot_started` → 쿠션 히트 → 목표 히트 → 샷 종료 함수를 호출했다. 이 상태는 일반 플레이의 자연 샷이 아닌 주입 테스트 상태다.
- 2쿠션은 원점수 10,000을 더해 **1,000,009,000**이 되었고, 3쿠션은 원점수 100,000을 더해 **1,000,099,000**이 되었다. `before/risk-2-cushions.png`, `before/risk-3-cushions.png`, `before/result.png` 및 `before/startup.mp4`에 Runner 화면을 기록했다.

## 변경 후

- `scripts/scr_game_rules/scr_game_rules.gml`에 `ENDLESS_SCORE_MAX = 999999999`를 선언했다. `rules_on_target_hit`에서 엔드리스에만 해당 샷의 실제 반영 가능 점수(`_credited_gain`)를 남은 여유분으로 제한하고, `rules_on_shot_ended`에서 가산 직후 `min(ENDLESS_SCORE_MAX, ...)`로 재차 제한한다. 위험샷 `10^` 및 일반 샷 `2^` 원점수 공식은 유지한다.
- 화면의 대기 점수, 큰 점수 효과, 타격 점수 호출도 실제 반영 가능 점수를 사용한다. 스토리와 클래식 가산은 바꾸지 않았다.
- 같은 주입 테스트에서 2쿠션과 3쿠션 모두 최종 점수와 BEST가 **999,999,999**를 넘지 않았다. `after/risk-2-cushions.png`, `after/risk-3-cushions.png`, `after/result.png` 및 `after/startup.mp4`를 확인했다. 결과 화면의 9자리 점수도 표시된다.
- Igor VM 정식 빌드 성공: `Build/endless_score_cap_release.win`, SHA256 `41D85AA0A7F739BDADF4A9B9D084716BB3DB8E186DD53A30A18A521EA174D7E2`. 테스트 전용 코드는 빌드 후 원래 소스로 복원했다. `python tools/test_game_mode_rules.py`와 `python tools/validate_project.py` 통과.

## 저장 파일 주의 및 복구

- 기존 저장 BEST가 이미 상한보다 크면 코드는 자동 초기화하거나 삭제하지 않는다. 수동 복구는 게임을 종료한 뒤 `C:\Users\user\AppData\Local\final_project\cushion_foul_void_save.ini`의 `[record]` 아래 `best_score_endless`와 호환용 `best_score` 두 값만 원하는 정상 BEST로 고치면 된다. `best_score_classic` 등 다른 항목은 그대로 둔다.
- 이 하네스는 실제 저장 함수도 실행했다. 테스트가 `best_score`와 `best_score_endless`를 합성 고득점으로 덮어쓴 것을 발견해, **사용자가 제공한 정상 BEST 1,005,370**으로 두 키를 복원했다. 복원 직전 두 키는 모두 `999999999.000000`, 복원 후 두 키는 모두 `1005370.000000`이다. 클래식 BEST `3600.000000`, 언어, 음량, 스토리 저장값은 변경하지 않았다. 테스트 전에 두 키의 실제 원래 값은 별도로 백업하지 않았으므로, 사용자 제공 값에 근거한 복원임을 명시한다.

## 남은 범위

- 2·3쿠션 검증은 실제 GML 규칙 함수와 Runner UI를 통한 주입 테스트이며 수동 당구 샷 재현은 아니다.
- 테스트 하네스를 다시 실행하면 실제 AppData BEST에 테스트 점수가 기록될 수 있으므로 실행 전 저장 파일 백업이 필요하다.

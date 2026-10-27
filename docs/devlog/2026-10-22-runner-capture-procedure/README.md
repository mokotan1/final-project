# Runner 실행·촬영 절차 정리 (2026-10-22)

## 배경

[2026-10-16 진단](../2026-10-16-runner-dll-diagnosis/after/README.md)에서 확인한 내용:

- 제한된 작업 환경: `Start-Process`로 `Runner.exe -game <.win>` 시 `{잘못된 DLL 재할당}` / NativeErrorCode **623**, 프로세스 미생성.
- 일반 데스크톱 PowerShell: 동일 Runner·동일 `.win`으로 창 생성 및 `capture_startup.ps1` 촬영 성공.

이번 작업은 게임 코드가 아니라 **도구·절차**만 다듬었다. 시스템 DLL·런타임 교체·보안 우회는 하지 않는다.

## 원인 경계 (고정)

| 구분 | 제한된 프로세스 환경 | 일반 데스크톱 PowerShell |
|------|----------------------|---------------------------|
| Runner 시작 | 실패 (DLL 재할당) | 성공 |
| 게임 `.win` / GML | 원인 아님 | 동일 빌드 사용 |
| `capture_existing_runner.ps1` | Runner를 사용자가 먼저 띄운 경우만 가능 | IDE/F5 또는 수동 Runner 후 촬영 |

에이전트·샌드박스 셸에서는 Runner를 코드로 “고칠” 수 없다. 데스크톱에서 검증된 스크립트만 사용한다.

## 작업 전 실험 (이 세션)

```powershell
# 1) 직접 Start-Process (에이전트 셸)
$runner = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23\windows\x64\Runner.exe'
$game = 'D:\final_project\Build\final_project.win'
$p = Start-Process -FilePath $runner -ArgumentList @('-game',$game) -WorkingDirectory (Split-Path $game) -PassThru
# 결과: PID 할당, MainWindowHandle 비영, 2초 후 종료 전 정상 (이 PC의 현재 셸은 제한 환경이 아님)

# 2) 기존 capture_startup (도구 수정 전)
.\tools\capture_startup.ps1 -GameFile $game -OutputDirectory docs\devlog\2026-10-22-runner-capture-procedure\verify-agent
# 결과: Captured 50 frames — verify-agent/initial.png, startup.mp4 생성
```

과거 일지(2026-10-16~19)의 실패는 **당시 셸이 제한 환경**이었을 때와 일치한다. 환경마다 다르므로 촬영 전에 항상 `test_runner_launch.ps1`을 실행한다.

## 작업 후 절차 (다음 세션용)

1. **데스크톱** PowerShell을 연다 (Cursor 터미널이 실패하면 Win+X → Terminal).
2. `cd D:\final_project`
3. `.\tools\test_runner_launch.ps1` → `CanLaunch: True` 확인.
4. 목적에 맞는 캡처:
   - `capture_startup.ps1` — 새 빌드 메뉴/첫 화면.
   - `capture_story_ai.ps1` — 검증 룸 + 드래그 샷.
   - `capture_existing_runner.ps1` — 게임을 이미 실행한 상태에서만.
5. 출력을 `docs/devlog/<날짜>-<작업>/before|after/`에 저장.

빠른 참조: [tools/RUNNER_CAPTURE.md](../../../tools/RUNNER_CAPTURE.md)

## 수정·추가 파일 (tools만)

| 파일 | 역할 |
|------|------|
| `tools/runner_capture_common.ps1` | Runner 경로, launch probe, 공통 `Start-Process` |
| `tools/test_runner_launch.ps1` | 환경 진단 (exit 0=가능, 2=불가) |
| `tools/RUNNER_CAPTURE.md` | 한 페이지 요약 |
| `tools/capture_startup.ps1` | 시작 전 `Assert-GamemakerRunnerLaunchEnvironment` |
| `tools/capture_story_ai.ps1` | 동일 |
| `tools/capture_existing_runner.ps1` | 주석: Runner 미시작, 데스크톱 선행 실행 |

## 작업 후 검증 (이 세션)

```powershell
.\tools\test_runner_launch.ps1
.\tools\test_runner_launch.ps1 -Json
```

에이전트 셸에서 probe·`capture_startup` 재실행이 성공했다. 제한 환경에서는 `RestrictedEnvironmentLikely: True`와 함께 exit 2 및 캡처 스크립트의 명시적 오류 메시지가 나와야 한다 (이 PC에서는 현재 재현되지 않음).

### Codex 검토에서 확인한 환경 차이

같은 날 별도 Codex 실행 환경에서는 Windows PowerShell 5.1이 `runner_capture_common.ps1`의 한글 정규식을 잘못 읽어 진단 명령이 먼저 실패했다. 정규식을 ASCII 패턴(`DLL|relocation`)과 오류 코드 검사로 바꾸고 다시 검증했다.

동일한 `Build/final_project.win`과 동일한 `Runner.exe`로 `tools/test_runner_launch.ps1 -GameFile D:\final_project\Build\final_project.win -Json`을 각각 실행했다.

| 실행 환경 | 관찰 |
| --- | --- |
| 제한된 기본 셸 | `ProcessStarted: false`, `{Illegal System DLL Relocation}`, `RestrictedEnvironmentLikely: true` |
| 일반 데스크톱 권한 | `ProcessStarted: true`, `CanLaunch: true`, `MainWindowHandle` 비영 |

따라서 프로브는 세션마다 실제 실행 가능 여부를 구별한다. **제한된 셸에서 Runner 자체를 실행 가능하게 만드는 수정은 아니다.** 해당 환경에서는 일반 데스크톱 권한으로 실행·촬영해야 한다.

## 실패 시

- `CanLaunch: False`, NativeErrorCode **623** 또는 메시지에 DLL/재할당: **환경 문제** — 데스크톱 PowerShell로 이동. 게임 수정 불필요.
- `CanLaunch: True`인데 캡처 실패: `ffmpeg` PATH, 창 크기, Runner 조기 종료(게임 크래시)를 확인.
- IDE만 사용: Runner를 수동 실행 후 `capture_existing_runner.ps1`만 사용.

# GameMaker Runner 실행·촬영

## 요약

일부 **제한된 프로세스 환경**(에이전트·샌드박스 셸 등)에서는 `Runner.exe`가 시작되기 전에 Windows가 `{잘못된 DLL 재할당}` / `{Illegal System DLL Relocation}`(종종 **NativeErrorCode 623**)을 반환합니다. 게임 `.win`이나 GML 문제가 아닙니다.

**일반 데스크톱**에서 연 PowerShell로 실행·촬영합니다. IDE에서 F5로 띄운 창만 촬영할 때는 Runner를 직접 시작하지 않습니다.

상세 진단: [2026-10-16-runner-dll-diagnosis](../docs/devlog/2026-10-16-runner-dll-diagnosis/after/README.md)  
절차·검증: [2026-10-22-runner-capture-procedure](../docs/devlog/2026-10-22-runner-capture-procedure/README.md)

## 사전 검사

```powershell
cd D:\final_project
.\tools\test_runner_launch.ps1
```

`CanLaunch: True`이면 캡처 스크립트를 같은 셸에서 실행할 수 있습니다. `False`이고 `RestrictedEnvironmentLikely: True`이면 데스크톱 PowerShell로 옮깁니다.

JSON 로그:

```powershell
.\tools\test_runner_launch.ps1 -Json | Set-Content -Encoding utf8 .\runner-launch-probe.json
```

## 캡처 명령

| 목적 | 명령 |
|------|------|
| 빌드 후 첫 화면 50프레임 | `.\tools\capture_startup.ps1 -GameFile D:\final_project\Build\final_project.win -OutputDirectory <out>` |
| 스토리 AI 샷 자동 입력 300프레임 | `.\tools\capture_story_ai.ps1 -GameFile ... -OutputDirectory ...` |
| 이미 열린 Runner 창 | 게임을 IDE/Runner로 먼저 실행한 뒤 `.\tools\capture_existing_runner.ps1 -OutputDirectory <out> -Frames 240` |

`ffmpeg`가 PATH에 있어야 mp4가 생성됩니다.

## Runner 경로

기본: `C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\<최신>\windows\x64\Runner.exe`  
다른 설치/런타임이면 환경 변수 `GMS2_RUNNER_EXE`에 전체 경로를 지정합니다.

## 환경 검사 건너뛰기

자동 프로브를 끄려면 (이미 데스크톱에서 Runner가 떠 있는 경우 등):

```powershell
.\tools\capture_startup.ps1 -SkipEnvironmentCheck ...
```

# Runner DLL 오류 진단 (2026-10-16)

- 제한된 작업 환경에서 `Runner.exe -game D:\final_project\Build\final_project.win`을 시작하면 PowerShell `Start-Process`가 `{잘못된 DLL 재할당}`을 반환했다. 게임 프로세스는 생성되지 않았다.
- 같은 Runner와 `.win` 파일을 일반 데스크톱 실행 권한으로 실행하면 창이 열리고 4초 뒤에도 실행 중이었다 (`MainWindowHandle=6557856`).
- 같은 권한으로 `tools/capture_startup.ps1`을 실행해 1280×720 화면 50프레임을 촬영했다. `initial.png`와 `startup.mp4`는 실제 Runner 출력이다.
- 따라서 이번 현상은 게임 코드나 패키지 DLL 수정 대상이 아니라 제한된 프로세스 실행 환경의 영향이다. Runner 실행·화면 촬영 명령은 일반 데스크톱 권한에서 실행한다.
- 실행·촬영 절차와 `tools/test_runner_launch.ps1` 환경 검사: [2026-10-22-runner-capture-procedure](../../2026-10-22-runner-capture-procedure/README.md), `tools/RUNNER_CAPTURE.md`.

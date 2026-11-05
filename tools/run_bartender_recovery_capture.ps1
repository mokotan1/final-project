param(
    [string]$OutputDirectory = 'D:\final_project\docs\devlog\2026-10-29-bartender-recovery-on-player-loss\after\capture-fixture',
    [ValidateRange(0, 2)][int]$RecoveryPhase = 0,
    [switch]$BuildOnly
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$intro = Join-Path $root 'objects/obj_story_intro/Create_0.gml'
$create = Join-Path $root 'objects/obj_story_versus_game/Create_0.gml'
$fixtureMarker = 'Temporary visual fixture for bartender recovery risk capture'
$createBase = "story_versus_init();`nstory_versus_spawn_layout();`nai_turn_delay = 0;`n"
function Get-StoryVersusCreateBaseText([string]$Text) {
    $idx = $Text.IndexOf($fixtureMarker)
    if ($idx -lt 0) { return $Text.TrimEnd() + "`n" }
    $head = $Text.Substring(0, $idx)
    $head = $head -replace '(?m)^global\.recovery_capture_phase\s*=.*\r?\n', ''
    return $createBase
}
$paths = @($intro, $create)
$original = @{}
foreach ($path in $paths) {
    $bytes = [IO.File]::ReadAllBytes($path)
    if ($path -eq $create) {
        $normalized = Get-StoryVersusCreateBaseText([Text.Encoding]::UTF8.GetString($bytes))
        $original[$path] = [Text.Encoding]::UTF8.GetBytes($normalized)
    } else {
        $original[$path] = $bytes
    }
}
$utf8 = [Text.UTF8Encoding]::new($false)
$igor = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23\bin\igor\windows\x64\Igor.exe'
$runtime = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23'
$runner = Join-Path $runtime 'windows\x64\Runner.exe'
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$game = Join-Path $OutputDirectory 'recovery_capture.win'
$fixture = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'bartender_recovery_capture_fixture.gml'), [Text.Encoding]::UTF8)
$fixtureBlock = "global.recovery_capture_phase = $RecoveryPhase;`n" + $fixture
try {
    $introSource = [Text.Encoding]::UTF8.GetString($original[$intro]).Replace('audio_volume_init();', "audio_volume_init();`nglobal.story_intro_match = true;`nroom_goto(rm_story_ai_verify);`nexit;")
    [IO.File]::WriteAllText($intro, $introSource, $utf8)
    [IO.File]::WriteAllText($create, $createBase + $fixtureBlock, $utf8)
    $buildLog = & $igor "--runtimePath=$runtime" "--project=$root\final_project.yyp" --runtime=VM `
        "--cache=$root\Build\cache_recovery_capture" "--temp=$root\Build\temp_recovery_capture" `
        "--of=$game" windows Compile 2>&1
    $buildLog | Set-Content -LiteralPath (Join-Path $OutputDirectory 'compile.log')
    if ($LASTEXITCODE -ne 0) { throw "Igor failed: $LASTEXITCODE" }
    $iff = @($buildLog | Where-Object { $_ -match 'Saving IFF file\.\.\.' } | Select-Object -Last 1)
    if ($iff.Count -ne 1) { throw 'IFF output path missing' }
    $built = ($iff[0] -replace '^.*Saving IFF file\.\.\.\s*', '').Trim()
    Copy-Item -LiteralPath $built -Destination $game -Force
    if ($BuildOnly) { return $game }
    $stdout = Join-Path $OutputDirectory 'runner_stdout.txt'
    $stderr = Join-Path $OutputDirectory 'runner_stderr.txt'
    $proc = Start-Process -FilePath $runner -ArgumentList @('-game', $game) -WorkingDirectory (Split-Path $game) `
        -RedirectStandardOutput $stdout -RedirectStandardError $stderr -PassThru -Wait
    "ExitCode=$($proc.ExitCode)" | Set-Content (Join-Path $OutputDirectory 'runner_exit.txt')
} finally {
    foreach ($path in $paths) { [IO.File]::WriteAllBytes($path, $original[$path]) }
}
Write-Output $game

param([switch]$Visual, [switch]$Autoplay)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$createFile = Join-Path $root 'objects/obj_story_versus_game/Create_0.gml'
$introFile = Join-Path $root 'objects/obj_story_intro/Create_0.gml'
$stepFile = Join-Path $root 'objects/obj_story_versus_game/Step_0.gml'
$harnessFile = Join-Path $PSScriptRoot $(if ($Visual) { 'story_50_visual_harness.gml' } else { 'story_50_runtime_harness.gml' })
$original = [System.IO.File]::ReadAllBytes($createFile)
$introOriginal = [System.IO.File]::ReadAllBytes($introFile)
$stepOriginal = [System.IO.File]::ReadAllBytes($stepFile)
$igor = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23\bin\igor\windows\x64\Igor.exe'
$runtime = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23'
try {
    if ($Autoplay) {
        $stepSource = [System.Text.Encoding]::UTF8.GetString($stepOriginal)
        $autoplaySource = [System.IO.File]::ReadAllText((Join-Path $PSScriptRoot 'story_50_autoplay_prefix.gml'), [System.Text.Encoding]::UTF8)
        [System.IO.File]::WriteAllText($stepFile, $autoplaySource + "`n" + $stepSource, [System.Text.UTF8Encoding]::new($false))
    } else {
        $source = [System.Text.Encoding]::UTF8.GetString($original)
        $harness = [System.IO.File]::ReadAllText($harnessFile, [System.Text.Encoding]::UTF8)
        [System.IO.File]::WriteAllText($createFile, $source + "`n" + $harness, [System.Text.UTF8Encoding]::new($false))
    }
    $introSource = [System.Text.Encoding]::UTF8.GetString($introOriginal)
    $introSource = $introSource.Replace('audio_volume_init();', "audio_volume_init();`nglobal.story_intro_match = true;`nroom_goto(rm_story_ai_verify);`nexit;")
    [System.IO.File]::WriteAllText($introFile, $introSource, [System.Text.UTF8Encoding]::new($false))
    $buildLog = & $igor "--runtimePath=$runtime" "--project=$root\final_project.yyp" --runtime=VM `
        "--cache=$root\Build\cache_story_50_runtime" "--temp=$root\Build\temp_story_50_runtime" `
        "--of=$root\Build\story_50_runtime_test.win" windows Compile
    if ($LASTEXITCODE -ne 0) { throw "Igor failed with exit code $LASTEXITCODE" }
    $outputName = if ($Autoplay) { 'story_50_autoplay.win' }
        elseif ($Visual) { 'story_50_visual_test.win' } else { 'story_50_runtime_test.win' }
    $iff = @($buildLog | Where-Object { $_ -match 'Saving IFF file\.\.\.' } | Select-Object -Last 1)
    if ($iff.Count -ne 1) { throw 'Igor did not report an IFF output path' }
    $built = ($iff[0] -replace '^.*Saving IFF file\.\.\.\s*', '').Trim()
    Copy-Item -LiteralPath $built `
        -Destination (Join-Path $root "Build/$outputName") -Force
} finally {
    [System.IO.File]::WriteAllBytes($createFile, $original)
    [System.IO.File]::WriteAllBytes($introFile, $introOriginal)
    [System.IO.File]::WriteAllBytes($stepFile, $stepOriginal)
}

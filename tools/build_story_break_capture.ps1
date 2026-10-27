$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$introFile = Join-Path $root 'objects/obj_story_intro/Create_0.gml'
$introOriginal = [IO.File]::ReadAllBytes($introFile)
$igor = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23\bin\igor\windows\x64\Igor.exe'
$runtime = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23'
try {
    $introSource = [Text.Encoding]::UTF8.GetString($introOriginal)
    $introSource = $introSource.Replace('audio_volume_init();', @"
audio_volume_init();
global.story_intro_match = true;
room_goto(asset_get_index(`"rm_story_ai_verify`"));
exit;
"@)
    [IO.File]::WriteAllText($introFile, $introSource, [Text.UTF8Encoding]::new($false))
    $buildLog = & $igor "--runtimePath=$runtime" "--project=$root\final_project.yyp" --runtime=VM `
        "--cache=$root\Build\cache_story_break_capture" "--temp=$root\Build\temp_story_break_capture" `
        "--of=$root\Build\story_break_capture.win" windows Compile
    if ($LASTEXITCODE -ne 0) { throw "Igor failed" }
    $iff = @($buildLog | Where-Object { $_ -match 'Saving IFF file\.\.\.' } | Select-Object -Last 1)
    if ($iff.Count -ne 1) { throw 'Igor did not report an IFF output path' }
    $built = ($iff[0] -replace '^.*Saving IFF file\.\.\.\s*', '').Trim()
    Copy-Item -LiteralPath $built -Destination (Join-Path $root 'Build/story_break_capture.win') -Force
    Write-Output "Built $built"
} finally {
    [IO.File]::WriteAllBytes($introFile, $introOriginal)
}

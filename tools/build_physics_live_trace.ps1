param(
    [string]$OutputWin = 'D:\final_project\Build\physics_live_trace_test.win'
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'runner_capture_common.ps1')

$root = Split-Path $PSScriptRoot -Parent
$createFile = Join-Path $root 'objects/obj_story_versus_game/Create_0.gml'
$introFile = Join-Path $root 'objects/obj_story_intro/Create_0.gml'
$stepFile = Join-Path $root 'objects/obj_story_versus_game/Step_0.gml'
$yyFile = Join-Path $root 'objects/obj_story_versus_game/obj_story_versus_game.yy'
$endStepFile = Join-Path $root 'objects/obj_story_versus_game/Step_2.gml'
$harnessFile = Join-Path $PSScriptRoot 'physics_live_trace_harness.gml'

$igor = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23\bin\igor\windows\x64\Igor.exe'
$runtime = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23'

$original = @{
    $createFile = [IO.File]::ReadAllBytes($createFile)
    $introFile = [IO.File]::ReadAllBytes($introFile)
    $stepFile = [IO.File]::ReadAllBytes($stepFile)
    $yyFile = [IO.File]::ReadAllBytes($yyFile)
}
$endStepExisted = Test-Path -LiteralPath $endStepFile
if ($endStepExisted) { $original[$endStepFile] = [IO.File]::ReadAllBytes($endStepFile) }

$utf8 = [Text.UTF8Encoding]::new($false)
$endStepEvent = '{"$GMEvent":"v1","%Name":"","collisionObjectId":null,"eventNum":2,"eventType":3,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},'

try {
    $introSource = [Text.Encoding]::UTF8.GetString($original[$introFile])
    $introSource = $introSource.Replace(
        'audio_volume_init();',
        "audio_volume_init();`nglobal.story_intro_match = true;`nroom_goto(rm_story_ai_verify);`nexit;"
    )
    [IO.File]::WriteAllText($introFile, $introSource, $utf8)

    $harness = [IO.File]::ReadAllText($harnessFile, [Text.Encoding]::UTF8)
    $createSource = [Text.Encoding]::UTF8.GetString($original[$createFile])
    [IO.File]::WriteAllText($createFile, $createSource + "`n" + $harness + "`nphysics_live_trace_setup_and_shoot();`n", $utf8)

    $stepPrefix = @'
if (variable_global_exists("physics_live_trace_active") && global.physics_live_trace_active) {
    global.story_dialogue_timer = 0;
    global.story_reaction_timer = 0;
    if (global.shot_active && physics_all_balls_stopped()) story_versus_on_shot_ended();
    exit;
}
'@
    $stepSource = [Text.Encoding]::UTF8.GetString($original[$stepFile])
    [IO.File]::WriteAllText($stepFile, $stepPrefix + "`n" + $stepSource, $utf8)

    $endStepGml = @'
if (!variable_global_exists("physics_live_trace_active") || !global.physics_live_trace_active) exit;
var _events = variable_global_exists("physics_live_trace_events") ? global.physics_live_trace_events : [];
global.physics_live_trace_events = [];
show_debug_message("PHYSICS_LIVE_TRACE_FRAME " + physics_live_trace_frame_json(global.physics_live_trace_step, _events));
global.physics_live_trace_step += 1;
if (global.physics_live_trace_step >= global.physics_live_trace_max) {
    physics_live_trace_finish("max_steps");
    exit;
}
if (!global.shot_active && physics_all_balls_stopped() && global.physics_live_trace_step > 2) {
    physics_live_trace_finish("settled");
}
'@
    [IO.File]::WriteAllText($endStepFile, $endStepGml, $utf8)

    $yySource = [Text.Encoding]::UTF8.GetString($original[$yyFile])
    if ($yySource -notmatch '"eventNum":2,"eventType":3') {
        $yySource = $yySource.Replace(
            '"eventList":[',
            '"eventList":[' + $endStepEvent
        )
        [IO.File]::WriteAllText($yyFile, $yySource, $utf8)
    }

    $buildLog = & $igor "--runtimePath=$runtime" "--project=$root\final_project.yyp" --runtime=VM `
        "--cache=$root\Build\cache_physics_live_trace" "--temp=$root\Build\temp_physics_live_trace" `
        "--of=$OutputWin" windows Compile 2>&1
    $buildLog | ForEach-Object { $_ }
    if ($LASTEXITCODE -ne 0) { throw "Igor failed with exit code $LASTEXITCODE" }
    $iff = @($buildLog | Where-Object { $_ -match 'Saving IFF file\.\.\.' } | Select-Object -Last 1)
    if ($iff.Count -ne 1) { throw 'Igor did not report an IFF output path' }
    $built = ($iff[0] -replace '^.*Saving IFF file\.\.\.\s*', '').Trim()
    Copy-Item -LiteralPath $built -Destination $OutputWin -Force
    Write-Output $OutputWin
} finally {
    [IO.File]::WriteAllBytes($createFile, $original[$createFile])
    [IO.File]::WriteAllBytes($introFile, $original[$introFile])
    [IO.File]::WriteAllBytes($stepFile, $original[$stepFile])
    [IO.File]::WriteAllBytes($yyFile, $original[$yyFile])
    if ($endStepExisted) {
        [IO.File]::WriteAllBytes($endStepFile, $original[$endStepFile])
    } elseif (Test-Path -LiteralPath $endStepFile) {
        Remove-Item -LiteralPath $endStepFile -Force
    }
}

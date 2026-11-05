param([Parameter(Mandatory)][string]$LogFile)
$ErrorActionPreference = 'Stop'
$lines = Get-Content -LiteralPath $LogFile
$slow = @()
foreach ($line in $lines) {
    if ($line -match 'BIG_SCORE_FRAME age=(\d+) ms=([0-9.]+)') {
        $age = [int]$Matches[1]
        $ms = [double]::Parse($Matches[2], [Globalization.CultureInfo]::InvariantCulture)
        if ($age -ge 4 -and $age -le 25 -and $ms -gt 50) {
            $slow += "age=$age ms=$ms"
        }
    }
}
if ($slow.Count -gt 0) { throw "Big score frame spikes over 50ms: $($slow -join ', ')" }
Write-Output 'PASS: no big-score frame over 50ms at ages 4-25'

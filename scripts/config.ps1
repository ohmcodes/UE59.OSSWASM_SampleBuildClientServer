# Shared paths for the sample's scripts. Override with environment variables if needed.
$EngineRoot  = if ($env:OSSWASM_ENGINE) { $env:OSSWASM_ENGINE } else { "D:\UE5 Source\UE59Prev2_SRC" }
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ProjectName = "OSSWASM_Sample"
$ProjectFile = Join-Path $ProjectRoot "$ProjectName.uproject"
$PackageDir  = Join-Path $ProjectRoot "Packaged"
$BackendUrl  = if ($env:OSSWASM_BACKEND_URL) { $env:OSSWASM_BACKEND_URL } else { "http://localhost:3000" }
$OutDir      = Join-Path $PSScriptRoot "out"
New-Item -ItemType Directory -Force $OutDir | Out-Null

# Writes a short summary (result + errors + first relevant warnings) of a UBT/UAT log. Returns $true on success.
function Write-BuildSummary([string]$Name, [string]$LogPath, [int]$ExitCode) {
    $summary = Join-Path $OutDir "$Name.summary.txt"
    $lines = Get-Content $LogPath -ErrorAction SilentlyContinue
    $errors = $lines | Where-Object { $_ -match "(?i)\berror\b|: fatal|undefined symbol|Unable to |ERROR:" -and $_ -notmatch "(?i)0 error|errors? *: *0|-ignoreerrors" } | Select-Object -Unique -First 40
    $warnings = $lines | Where-Object { $_ -match "(?i)\bwarning\b" -and $_ -match "OnlineSubsystemWASM|WasmOss|$ProjectName" } | Select-Object -Unique -First 15
    $result = $lines | Where-Object { $_ -match "^Result: |BUILD SUCCESSFUL|AutomationTool exiting with ExitCode|BuildCookRun time" } | Select-Object -Last 2
    $out = @("$Name : " + $(if ($ExitCode -eq 0) { "PASS" } else { "FAIL (exit $ExitCode)" }), "result: $($result -join ' | ')", "log: $LogPath")
    if ($errors) { $out += "--- errors"; $out += $errors }
    if ($warnings) { $out += "--- project/plugin warnings"; $out += $warnings }
    $out | Set-Content -Encoding utf8 $summary
    $out | ForEach-Object { Write-Host $_ }
    return ($ExitCode -eq 0)
}

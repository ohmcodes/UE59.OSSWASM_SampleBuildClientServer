# Packages the game with the source engine (BuildCookRun). Output goes to Packaged\<Platform>.
# Summary: scripts/out/package-*.summary.txt; full log next to it.
#   ./scripts/package.ps1                       -> Windows client + WindowsServer (Development)
#   ./scripts/package.ps1 -What Server          -> WindowsServer only
#   ./scripts/package.ps1 -What Client          -> Windows client only
#   ./scripts/package.ps1 -What Client -ClientPlatform Wasm   -> web client
param(
    [ValidateSet("Both", "Client", "Server")] [string]$What = "Both",
    [string]$ClientPlatform = "Win64",
    [string]$Configuration = "Development"
)
. "$PSScriptRoot\config.ps1"

$uatArgs = @(
    "BuildCookRun", "-project=$ProjectFile", "-unattended", "-utf8output", "-nop4",
    "-build", "-cook", "-iterate", "-stage", "-pak", "-archive", "-archivedirectory=$PackageDir"
)
if ($What -ne "Server") { $uatArgs += @("-platform=$ClientPlatform", "-clientconfig=$Configuration") }
if ($ClientPlatform -eq "Wasm") {
    # Web builds need IoStore containers and -package (writes wasm-manifest.json, wasm-cache.json and the .br copies).
    $uatArgs += @("-iostore", "-package", "-AdditionalCookerOptions=-unattended -nopause -nosplash -nullrhi")
    # Wasm archives the web site straight into -archivedirectory (and symbols into <dir>-Debug), so give it its own folder.
    $uatArgs = $uatArgs | ForEach-Object { if ($_ -like "-archivedirectory=*") { "-archivedirectory=$(Join-Path $PackageDir 'Wasm')" } else { $_ } }
    if (-not $env:WASM_EMSDK_ROOT) { $env:WASM_EMSDK_ROOT = [Environment]::GetEnvironmentVariable("WASM_EMSDK_ROOT", "User") }
    if (-not $env:WASM_EMSDK_ROOT) { Write-Error "WASM_EMSDK_ROOT is not set (emsdk 6.0.10). See guide 04."; exit 1 }
}
if ($What -ne "Client") { $uatArgs += @("-server", "-serverplatform=Win64", "-serverconfig=$Configuration") }
if ($What -eq "Server") { $uatArgs += "-noclient" }

$name = "package-$What-$ClientPlatform".ToLower()
$log = Join-Path $OutDir "$name.log"
Write-Host "Packaging ($What, client platform $ClientPlatform) ... full log: $log"
$start = Get-Date
& (Join-Path $EngineRoot "Engine\Build\BatchFiles\RunUAT.bat") @uatArgs *> $log
$code = $LASTEXITCODE
Write-Host ("Took {0:N0} min" -f ((Get-Date) - $start).TotalMinutes)
if (-not (Write-BuildSummary $name $log $code)) { exit 1 }
Get-ChildItem $PackageDir -Directory -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "  output: $($_.FullName)" }

# Compiles one target from the command line (close the editor first). Summary: scripts/out/build-*.summary.txt
#   ./scripts/build.ps1                         -> OSSWASM_SampleEditor Win64 Development
#   ./scripts/build.ps1 -Target Server          -> OSSWASM_SampleServer Win64 Development
#   ./scripts/build.ps1 -Target Game -Platform Wasm
param(
    [ValidateSet("Editor", "Game", "Server")] [string]$Target = "Editor",
    [string]$Platform = "Win64",
    [string]$Configuration = "Development"
)
. "$PSScriptRoot\config.ps1"

$targetName = switch ($Target) { "Editor" { "${ProjectName}Editor" } "Server" { "${ProjectName}Server" } default { $ProjectName } }
$name = "build-$Target-$Platform".ToLower()
$log = Join-Path $OutDir "$name.log"
Write-Host "Building $targetName $Platform $Configuration ..."
& (Join-Path $EngineRoot "Engine\Build\BatchFiles\Build.bat") $targetName $Platform $Configuration "-Project=$ProjectFile" -WaitMutex *> $log
if (-not (Write-BuildSummary $name $log $LASTEXITCODE)) { exit 1 }

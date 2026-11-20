# Starts the packaged dedicated server in its own window. It registers with the backend and shows up in the server list.
#   ./scripts/run-server.ps1                    -> port 7777, "Local 1"
#   ./scripts/run-server.ps1 -Port 7778 -Name "Local 2"
param(
    [int]$Port = 7777,
    [string]$Name = "Local $Port",
    [string]$ServerKey = $(if ($env:OSSWASM_SERVER_KEY) { $env:OSSWASM_SERVER_KEY } else { "dev-server-key" }),
    [string]$PublicAddress = "127.0.0.1:$Port"
)
. "$PSScriptRoot\config.ps1"

$exe = Get-ChildItem (Join-Path $PackageDir "WindowsServer") -Recurse -Filter "${ProjectName}Server*.exe" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match "\\Binaries\\Win64\\" -or $_.DirectoryName -eq (Join-Path $PackageDir "WindowsServer") } | Select-Object -First 1
if (-not $exe) { Write-Error "No packaged server in $PackageDir\WindowsServer. Run ./scripts/package.ps1 first."; exit 1 }

$log = "WasmOssServer_$Port.log"
$serverArgs = @("-log", "-port=$Port", "-WasmOssBackendUrl=$BackendUrl", "-WasmOssServerKey=$ServerKey",
    "-WasmOssPublicAddress=$PublicAddress", "-WasmOssServerName=`"$Name`"", "-ABSLOG=`"$(Join-Path $OutDir $log)`"")
Write-Host "Starting $($exe.FullName) $($serverArgs -join ' ')"
Start-Process -FilePath $exe.FullName -ArgumentList $serverArgs
Write-Host "Server log: $(Join-Path $OutDir $log)"

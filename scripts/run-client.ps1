# Starts the packaged Windows client in a window. It never connects by itself: use the menu (server list or direct IP).
# In the client, press ` (console) for: wasmoss.Login, wasmoss.Servers, wasmoss.Join 0, wasmoss.Connect <host:port>
#   ./scripts/run-client.ps1 [-Instance 2]
param(
    [int]$Instance = 1
)
. "$PSScriptRoot\config.ps1"

$exe = Get-ChildItem (Join-Path $PackageDir "Windows") -Filter "$ProjectName.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $exe) { Write-Error "No packaged client in $PackageDir\Windows. Run ./scripts/package.ps1 first."; exit 1 }

$log = "WasmOssClient_$Instance.log"
$clientArgs = @("-windowed", "-resx=1280", "-resy=720", "-log", "-WasmOssBackendUrl=$BackendUrl", "-ABSLOG=`"$(Join-Path $OutDir $log)`"")
if ($Instance -gt 1) { $clientArgs += "-WasmOssGuestSuffix=$Instance" }  # a different guest player per local client
Start-Process -FilePath $exe.FullName -ArgumentList $clientArgs
Write-Host "Client log: $(Join-Path $OutDir $log)"

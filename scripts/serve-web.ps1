# Serves the packaged web client and starts the WebSocket relay, both on this PC.
#   ./scripts/serve-web.ps1            -> http://localhost:8080/index.html  (relay on ws://localhost:8889)
# Open the page in Chrome or Edge. A second tab that should be another player (Development builds only): ?args=-WasmOssGuestSuffix=2
# Ctrl+C stops both.
param(
    [int]$Port = 8080,
    [int]$RelayPort = 8889
)
. "$PSScriptRoot\config.ps1"

$python = Join-Path $EngineRoot "Engine\Binaries\ThirdParty\Python3\Win64\python.exe"
$tools  = Join-Path $EngineRoot "Engine\Platforms\Wasm\Build\Tools\web"
$stage  = Join-Path $PackageDir "Wasm"
if (-not (Test-Path (Join-Path $stage "index.html"))) { Write-Error "No web build in $stage. Run ./scripts/package.ps1 -What Client -ClientPlatform Wasm first."; exit 1 }

# The relay turns the game's WebSocket messages into UDP to the dedicated server. By default it listens on 127.0.0.1
# and only relays to loopback and private addresses, and only for pages served from this machine.
$relayLog = Join-Path $OutDir "ws_relay.log"
$relay = Start-Process -FilePath $python -ArgumentList @("-I", "`"$tools\ws_relay.py`"", "--port", $RelayPort) `
    -RedirectStandardOutput $relayLog -RedirectStandardError "$relayLog.err" -PassThru -WindowStyle Hidden
Write-Host "Relay: ws://localhost:$RelayPort (log $relayLog)"
Write-Host "Game:  http://localhost:$Port/index.html"
try {
    & $python -I "$tools\serve.py" --root $stage --port $Port
} finally {
    if (-not $relay.HasExited) { Stop-Process -Id $relay.Id -Force }
}

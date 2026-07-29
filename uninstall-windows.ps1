# uninstall-windows.ps1 - remove Clawdmeter autostart and managed local state.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File uninstall-windows.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Log {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message"
}

$RepoRoot = $PSScriptRoot
if (-not $RepoRoot) {
    $RepoRoot = (Get-Location).Path
}

$RunKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$VenvDir = Join-Path $RepoRoot ".venv"
$DataDir = Join-Path $env:LOCALAPPDATA "Clawdmeter"

Log "=== Clawdmeter Windows uninstall ==="

# The tray application and the usage daemon run in one Python process. Match
# only Clawdmeter's entry script so unrelated Python processes are preserved.
$trayProcesses = Get-CimInstance Win32_Process -Filter "Name = 'pythonw.exe' OR Name = 'python.exe'" |
    Where-Object { $_.CommandLine -and $_.CommandLine -like "*daemon\tray_windows.py*" }
foreach ($process in $trayProcesses) {
    Stop-Process -Id $process.ProcessId -Force
    Log "Stopped tray process $($process.ProcessId)"
}

Remove-ItemProperty -Path $RunKey -Name "Clawdmeter" -ErrorAction SilentlyContinue
Log "Removed login autostart entry (or it was already absent)"

foreach ($path in @($VenvDir, $DataDir)) {
    if (Test-Path -LiteralPath $path) {
        Remove-Item -LiteralPath $path -Recurse -Force
        Log "Removed: $path"
    } else {
        Log "Already absent: $path"
    }
}

Log "=== Uninstall complete ==="
Log "Bluetooth pairing, Claude credentials, uv, and this repository were preserved."

###############################################################################
# run_dev.ps1 — 4Directions Farm App development runner
#
# Runs the app on the requested target and pipes ALL flutter output (which
# includes every AppLogger.debugPrint line) to:
#
#   logs\android_YYYY-MM-DD.log   — when target = android  (default)
#   logs\web_YYYY-MM-DD.log       — when target = web
#   logs\app_YYYY-MM-DD.log       — when target = all (runs both in parallel)
#
# Usage
#   .\run_dev.ps1                  # android emulator (default)
#   .\run_dev.ps1 -Target web      # Chrome
#   .\run_dev.ps1 -Target android  # Android emulator
#   .\run_dev.ps1 -Target all      # Both in separate windows
###############################################################################

param(
    [ValidateSet('android','web','all')]
    [string]$Target = 'android'
)

$flutter = 'C:\flutter\bin\flutter.bat'
$logsDir = Join-Path $PSScriptRoot 'logs'
if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory $logsDir | Out-Null }

$date = (Get-Date -Format 'yyyy-MM-dd')

function Invoke-Target {
    param([string]$device, [string]$logName)

    $logFile = Join-Path $logsDir "${logName}_${date}.log"
    $separator = "`n========== SESSION START $(Get-Date -Format 'o') =========="
    Add-Content -Path $logFile -Value $separator

    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  Target  : $device" -ForegroundColor Cyan
    Write-Host "  Log file: $logFile" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""

    # Run flutter and tee every line to the log file AND the terminal
    & $flutter run -d $device --debug 2>&1 | Tee-Object -FilePath $logFile -Append
}

switch ($Target) {
    'android' {
        # Make sure JAVA_HOME is set for the build
        if (-not $env:JAVA_HOME) {
            $env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
        }
        Invoke-Target -device 'emulator-5554' -logName 'android'
    }
    'web' {
        Invoke-Target -device 'chrome' -logName 'web'
    }
    'all' {
        # Launch android in this window, web in a new window
        Start-Process powershell -ArgumentList "-NoExit -Command `"cd '$PSScriptRoot'; .\run_dev.ps1 -Target web`""
        if (-not $env:JAVA_HOME) {
            $env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
        }
        Invoke-Target -device 'emulator-5554' -logName 'android'
    }
}

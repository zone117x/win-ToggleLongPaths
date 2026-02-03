@echo off
set "PS1_URL=https://raw.githubusercontent.com/zone117x/win-ToggleLongPaths/main/ToggleLongPaths.ps1"
set "PS1_PATH=%TEMP%\ToggleLongPaths.ps1"

echo Downloading ToggleLongPaths.ps1...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%PS1_URL%' -OutFile '%PS1_PATH%'"
if %ERRORLEVEL% neq 0 (
    echo Failed to download script.
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1_PATH%"
del "%PS1_PATH%" 2>nul
exit /b

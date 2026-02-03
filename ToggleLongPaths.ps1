# --- Self-Elevation Block ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrative privileges..." -ForegroundColor Yellow
    if ($PSCommandPath) {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    } else {
        $tmpScript = Join-Path $env:TEMP "ToggleLongPaths.ps1"
        $MyInvocation.MyCommand.ScriptBlock | Set-Content -Path $tmpScript -Encoding UTF8
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$tmpScript`"" -Verb RunAs
    }
    exit
}
# ----------------------------

function Get-LongPathStatus {
    $val = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -ErrorAction SilentlyContinue
    if ($null -eq $val) { return 0 }
    return $val.LongPathsEnabled
}

function Set-LongPath {
    param([int]$Value)
    try {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value $Value -ErrorAction Stop
        Write-Host "`nSetting updated successfully!" -ForegroundColor Green
        Write-Host "Note: You may need to restart your computer or File Explorer for changes to apply." -ForegroundColor Yellow
    } catch {
        Write-Host "`nFailed to update registry. Ensure you granted admin permissions." -ForegroundColor Red
    }
}

do {
    $currentStatus = Get-LongPathStatus
    $statusText = if ($currentStatus -eq 1) { "ENABLED" } else { "DISABLED" }
    $statusColor = if ($currentStatus -eq 1) { "Green" } else { "Red" }

    Clear-Host
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "      WINDOWS LONG PATHS CONFIGURATION TOOL" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host -NoNewline "Current Status: "
    Write-Host $statusText -ForegroundColor $statusColor
    Write-Host "-----------------------------------------------"
    Write-Host "1. Enable Long Paths"
    Write-Host "2. Disable Long Paths"
    Write-Host "3. Restart File Explorer (Apply changes)"
    Write-Host "4. Exit"
    Write-Host "-----------------------------------------------"
    
    $choice = Read-Host "Select an option [1-4]"

    switch ($choice) {
        "1" { Set-LongPath -Value 1; Pause }
        "2" { Set-LongPath -Value 0; Pause }
        "3" { 
            Write-Host "Restarting Explorer..." -ForegroundColor Yellow
            Get-Process explorer | Stop-Process -Force
            Start-Sleep -Seconds 1
            Start-Process explorer.exe
            Write-Host "Done!" -ForegroundColor Green
            Pause
        }
        "4" { break }
        default { Write-Host "Invalid selection, try again." -ForegroundColor Yellow; Start-Sleep -Seconds 1 }
    }
} while ($choice -ne "4")
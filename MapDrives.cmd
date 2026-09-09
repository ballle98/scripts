@echo off
if exist "%USERPROFILE%\MapDrivesCredential.txt" goto run_logged

PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0MapDrives.ps1"
set "MapDrivesExitCode=%ERRORLEVEL%"
if not "%MapDrivesExitCode%"=="0" pause
exit /b %MapDrivesExitCode%

:run_logged
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0MapDrives.ps1" >> "%TEMP%\MapDrives.log" 2>&1
set "MapDrivesExitCode=%ERRORLEVEL%"
if "%MapDrivesExitCode%"=="0" exit /b 0
echo MapDrives failed. See "%TEMP%\MapDrives.log" for details.
pause
exit /b %MapDrivesExitCode%

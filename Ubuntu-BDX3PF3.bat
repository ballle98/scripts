powershell -nologo -command "Get-CimInstance Win32_Process -Filter \"Name='ssh.exe'\" | Where-Object { $_.CommandLine -match '-N\s+ubuntu-bdx3pf3' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }"

start /min ssh -N ubuntu-bdx3pf3

:wait_for_tunnel
powershell -nologo -command "if (Get-NetTCPConnection -LocalPort 5901 -State Listen -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if errorlevel 1 (
    timeout /t 1 /nobreak >nul
    goto wait_for_tunnel
)

start "" "C:\Program Files\RealVNC\VNC Viewer\vncviewer.exe" "C:\Users\Lee_Ballard\OneDrive - Dell Technologies\Documents\vnc\127.0.0.1-5901.vnc"

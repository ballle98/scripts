start /min ssh -N ubuntu-bdx3pf3

:wait_for_tunnel
powershell -nologo -command "try { $c = [Net.Sockets.TcpClient]::new(); $c.Connect('127.0.0.1', 5901); $c.Close(); exit 0 } catch { exit 1 }"
if errorlevel 1 (
    timeout /t 1 /nobreak >nul
    goto wait_for_tunnel
)

start "" "C:\Program Files\RealVNC\VNC Viewer\vncviewer.exe" "C:\Users\Lee_Ballard\OneDrive - Dell Technologies\Documents\vnc\127.0.0.1-5901.vnc"

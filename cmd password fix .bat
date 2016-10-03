echo [on] [Created By Disharuhdin@DELL]

taskkill /F /IM iexplore.exe
taskkill /f /IM outlook.exe 

cmdkey.exe /list > "%TEMP%\List.txt"
findstr.exe Target "%TEMP%\List.txt" > "%TEMP%\tokensonly.txt"
FOR /F "tokens=1,2 delims= " %%G IN (%TEMP%\tokensonly.txt) DO cmdkey.exe /delete:%%
del "%TEMP%\*.*" /s /f /q

rd /s /q %temp%
mkdir %temp%

del "%temp%" /s /q 
del "%tmp%" /s /q

RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255

echo [off]

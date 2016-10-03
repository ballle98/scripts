#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#v::
   IfWinExist PuTTY Fatal Error
   {
      Winactivate
      send, {enter}
   }
   IfWinExist PuTTY (inactive)
   {
      Winactivate
      send, !{space}r
   }
   If !WinExist("ahk_class PuTTY")
   {
      Run, putty -load "cdt-r720-3"
   }
   Run, C:\Users\lee_ballard\AppData\Roaming\RealVNC\VNC Address Book\cdt-r720-3 corp.vnc
   return
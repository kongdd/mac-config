#Requires AutoHotkey v2.0

; scoop install authhotkey

#HotIf WinActive("ahk_exe rustdesk.exe")
LAlt::LWin
LWin::LAlt
; RAlt::RWin
; RWin::RAlt
#HotIf

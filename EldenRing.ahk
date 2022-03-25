;EldenRing.ahk by DarKcyde
;Features: Keys for Run, instant Roll, backsetp, 2hand, use pockets
;Exit to Main Menu macro
;QoL bindings for menus (PgUp, PgDn, Enter)

#SingleInstance Force
#Warn  
if not A_IsAdmin
	Run *RunAs "%A_ScriptFullPath%"
Process Priority,,AboveNormal ;probably not needed?
Sendmode Input

global RollDashKey := "p"
global DisableWASD := 0
global tic := ""


F9::Reload

#IfWinActive ahk_exe eldenring.exe

`::g            ;map
F12::Suspend     ;Toggle for typing
LWIN::send {shift down}{space down}      ;alternate jump
LWIN up::send {shift up}{space up}
*CapsLock:: Send {Ctrl down}  ;crouch for easy press in combat
*CapsLock up:: Send {Ctrl up} ;separate down/up more reliable
tab::esc        ;menu
<!tab::alttab   ;overrides ESC when doing alt-tab
<!F4::send {LAlt down}{F4 down}{LAlt up}{F4 up}  


;QoL for the menus
enter::e
PgUp::c
PgDn::v
Delete::r
End::q
Home::f
Insert::g

~*Lshift::      ;run, no roll
	tic:=A_TickCount
	if IsMoving() 
		send {%RollDashKey% down}
	SetTimer, shiftup, % (toc:=A_TickCount-tic)<500 ? - (500-toc) : -25  ;prevents backstep
return

shiftup:
	if ( GetKeyState("LShift", "p") AND !GetKeyState(RollDashKey) AND IsMoving() )  ;Physically down, logically up
		send {%RollDashKey% down}           ;started moving or run interrupted
	if GetKeyState("LShift", "p")
		SetTimer, shiftup, -25     ;Key down still, loop again
	else
	{
		send {%RollDashKey% Up}             ;key released, send keyup
		tic:=""
	}
return

~*space::        ;roll no delay, does not run
	TapKey(RollDashKey)
return

*z:: ;Hold for 2hand-Left
	ThisKey := % LTrim(A_ThisHotkey, "*~^!+#<>$")
	KeyWait %ThisKey%, T0.250
    If !ErrorLevel  ;tap
	{
		TapKey("z",25,ThisKey)
    }  
	Else ;hold            
	{
		QuickUse("q")
		KeyWait %ThisKey%, T10
    }
return


*x:: ;Hold for 2hand-Right
	ThisKey := % LTrim(A_ThisHotkey, "*~^!+#<>$")
	KeyWait %ThisKey%, T0.250
    If !ErrorLevel  ;tap
	{
		TapKey("x",25,ThisKey)
    }  
	Else ;hold            
	{
		QuickUse("LButton")
		KeyWait %ThisKey%, T10
    }
return

;BackStep - usable while moving
*f::
	ThisKey := % LTrim(A_ThisHotkey, "*~^!+#<>$")
	KeyWait %ThisKey%, T0.200
	If !ErrorLevel     ;Tap
	{
		Thread NoTimers, true  ;running could interrupt
		if (IsMoving())
		{
			ReleaseKeys("wasd")
			DisableWASD := true
			send {%RollDashKey%	up} ; in case running
			sleep 25
		}
		TapKey(RollDashKey)
		sleep 25
		if (DisableWASD)
		{
			DisableWASD := false
			MoveKeys := "wasd"
			Loop, Parse, MoveKeys
			{
				if ( GetKeyState(A_LoopField, "p"))
					Send {%A_LoopField% down}
			}
		}
		Thread NoTimers, false
	}
	Else TapKey("f",25,ThisKey) ;Long hold, send F key
return

;Switch weapon, spell, item keys. 
;Backup in case needed, mapped to scroll wheel.
*F1::left
*F2::right
*F3::up
*F4::down

;Quick Pockets keys
;Hold to go back to first item
*1::QuickUse("left")
*2::QuickUse("right")
*3::
	ThisKey := % LTrim(A_ThisHotkey, "*~^!+#<>$$")
	KeyWait %ThisKey%, T0.200
    If !ErrorLevel           ;tap       
	    QuickUse("up")
	Else                            
	{
		TapKey("up", 550,ThisKey)  ;long press to go back to first item
    }
return

*4::
	ThisKey := % LTrim(A_ThisHotkey, "*~^!+#<>$")
	KeyWait %ThisKey%, T0.200  
    If !ErrorLevel            ;tap     
	    QuickUse("down")
	Else                            
	{
		TapKey("down", 550,ThisKey)  ;long press to go back to first item
    }
return

;Pocket 5
*c::MenuClick(1750,470)

;Pocket 6
*v::MenuClick(1840,470)

;Exit to Main Menu 
Pause::
	TapKey("ESC")
	sleep 500
	TapKey("up")
	sleep 200
	TapKey("e")
	sleep 100
	TapKey("z")
	sleep 100
	TapKey("e")
	sleep 200
	TapKey("left")
	sleep 500
	TapKey("e")
return

;Gestures
Numpad7::MenuClick(1750,620)
Numpad8::MenuClick(1840,620)
Numpad4::MenuClick(1750,710)
Numpad5::MenuClick(1840,710)
Numpad1::MenuClick(1750,800)
Numpad2::MenuClick(1840,800)

#IfWinActive  ;END HOTKEYS

;=============
;FUNCTIONS
;=============
IsMoving() {
	if GetKeyState("w","P") OR GetKeyState("a","P") OR GetKeyState("s","P") OR GetKeyState("d","P")
		return 1
	else 
		return 0
}

; TapKey() Function
; key = press this
; delay = sleep in ms
; stopAutoRepeat = key to wait for keyup, usually A_ThisHotkey
TapKey(key, delay := 25, stopAutoRepeat := "") {
	send {%key% down}
    Sleep %delay%
	send {%key% up}
	if (stopAutoRepeat)         
		KeyWait %stopAutoRepeat%, T5
	return
}

; QuickUse() Function
; Holds Interact and presses Key
; Lbutton and Q for 2hand left/right
; Pocket keys up/dn/left/right
QuickUse(key) {
	send {e down}
	;sleep 31
	send {%key% down}
	sleep 50
	send {e up}
	send {%key% up}
	return
}

; Function that release all the letters in the str variable
ReleaseKeys(str){
    Loop, Parse, % str  ; Loop through each character of the variable str
        Send {%A_LoopField% Up}
    Return
}

; Directive disables WASD when true
#if (DisableWASD)
	*w::
	*a::
	*s::
	*d::
	return
#if

; Pockets 5,6 and Gestures
MenuClick(x,y) {
	local
	SetMouseDelay 25
	ThisKey := % LTrim(A_ThisHotkey, "*~^!+#<>$")
	TapKey("ESC")
	SendEvent {click %x% %y%}
	TapKey("ESC")
	Keywait %ThisKey%, T5
}
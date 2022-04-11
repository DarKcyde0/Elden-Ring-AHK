;EldenRing.ahk by DarKcyde
;Features: Keys for Run, instant Roll, backstep (while moving), 2hand, use pockets
;Macros for Exit to Main Menu, Pause, teleport to RoundTable
;QoL bindings for menus (PgUp, PgDn, Enter)

; Depends on modified fork at https://github.com/DarKcyde0/TapHoldManager for keydown
#include <TapHoldManager>
#SingleInstance Force
#Warn 
#MenuMaskKey vkFF ; solves extraneous CTRL presses
#NoEnv
#MaxHotkeysPerInterval 200 ;managed to get warning at default 70
; If hotkey response time is crucial (such as in games) and the script contains any timers whose subroutines take longer
; than about 5 ms to execute, use the following command to avoid any chance of a 15 ms delay.
Thread, interrupt, 0  ; Make all threads always-interruptible
if not A_IsAdmin
	Run *RunAs "%A_ScriptFullPath%"
Process Priority,,AboveNormal ;probably not needed?
Sendmode Input

global RollDashKey := "p"
global UseKey := "o"
global DisableWASD := 0
global tick := ""
global runtimer := ""

;thm := new TapHoldManager([ <tapTime := -1>, holdTime := -1, <maxTaps := -1>, <prefix := "$">, <window := ""> ])
TapMgr := new TapHoldManager(-1,-1,2,"*","ahk_exe eldenring.exe")

TapMgr.Add("MButton",Func("MbuttonMgr"))
TapMgr.Add("z",Func("z_func"))
TapMgr.Add("c",Func("c_func"))
TapMgr.Add("f",Func("f_func"))
; TapMgr.Add("lshift",Func("run_func"),200,500,2,"~*")

TapMgr.Add("w",Func("DoubleTapMoves_Run").Bind("w"),-1,-1,2,"~*")
; TapMgr.Add("a",Func("DoubleTapMoves_Run").Bind("a"),-1,-1,2,"~*")
; TapMgr.Add("s",Func("DoubleTapMoves_Run").Bind("s"),-1,-1,2,"~*")
; TapMgr.Add("d",Func("DoubleTapMoves_Run").Bind("d"),-1,-1,2,"~*")


#IfWinActive ahk_exe eldenring.exe   

F9::Reload       ;for AHK tweaking
F12::Suspend     ;Toggle on/off

; Mouse remap, best accomplished with mouse driver software
; *WheelLeft::left
; *WheelRight::right
; *Xbutton1::u  ;remapped below to Q
; *Xbutton2::r

; REMAPS
;===============
`::ToggleMap()
LWIN::send {shift down}{space down}					;alternate jump
LWIN up::send {shift up}{space up}
*CapsLock:: Send {Ctrl down}						;crouch for easy press in combat
*CapsLock up:: Send {Ctrl up}						;separate down/up more reliable
tab::esc											;menu
<!tab::alttab										;overrides ESC when doing alt-tab
<!F4::send {LAlt down}{F4 down}{LAlt up}{F4 up}  


;QoL for the menus
enter::e
PgUp::c
PgDn::v
Delete::r
End::q
Home::f
Insert::g

; Attempt at replacing Run with TapHoldManager, untested, not currently using.
run_func(isHold, taps, keydown){
	if (taps==1 && isHold==0 && keydown==1) ;on key down
	{
		if (!tick)
			tick:=A_tickCount
		if IsMoving() 						; Will backstep if not moving
			send {%RollDashKey% down}
		SetTimer, RunMgr, 17                ; 60fps is 16.7ms
	}
	if (isHold && !keydown) ; held for 500ms and keyup
		SetTimer RunMgr, Off
		StopRunning()
	if (taps && !isHold && state==-1) ; released before 500ms, prevent backstep
	{
		SetTimer RunMgr, Off
		SetTimer StopRunning, % - (500 - (A_TickCount-tick))  ; calculate how much time to keep key down for 500ms
		tick := ""
	}
}

; Dedicated Run key
~*Lshift::
	if (!tick)
		tick:=A_tickCount
	if IsMoving() 						; Will backstep if not moving
		send {%RollDashKey% down}
	SetTimer, RunMgr, 17                ; 60fps is 16.7ms
	Keywait Lshift						; prevent autorepeat
return

~*Lshift Up::
    SetTimer RunMgr, Off
	SetTimer StopRunning, % (tock:=A_TickCount-tick)<500 ? - (500-tock) : -0   ; calculate how much time to keep key down for 500ms
return

StopRunning() {
	if (!GetKeyState("Lshift","P")){  ;In case Run pressed during timer
		send {%RollDashKey% Up}
		tick := ""
	}
}

RunMgr() {
    if ( !GetKeyState(RollDashKey) AND IsMoving() )   ;started moving or run interrupted
        send {%RollDashKey% down}
}

; Dedicated Roll key, no input lag
; Default happens on key Up, this fires on key Down.
~*space:: 
	TapKey(RollDashKey)
return


;Switch weapon, spell, item keys. 
;Backup in case needed, mapped to scroll wheel.
*F1::left
*F2::right
*F3::up
*F4::down

;Quick Pockets keys
*q::QuickUse("up")			;Pocket 1 (red flask)
*e::QuickUse("right")		;Pocket 2 (blue flask)
*1::QuickUse("left")		;Pocket 3 (Horse pocket)
*2::QuickUse("down")		;Pocket 4 (Physick flask)
*3::MenuClick(1750,470)		;Pocket 5 (Lantern)
*4::MenuClick(1840,470)		;Pocket 6 (power ups, varies)

; REMAP Q & E
u::q  ;mouse back
i::e  ;mouse side btn

;Exit to Main Menu 
NumpadSub::
	TapKey("ESC")
	TapKey("up")
	TapKey("e")
	Sleep 25
	TapKey("z")
	TapKey("e")
	Sleep 25
	TapKey("left")
	TapKey("e")
return

Pause::
	TapKey("ESC")
	TapKey("e")
	sleep 25
	TapKey("g")
	TapKey("up")
	TapKey("e")
return

;Teleport to Roundtable Hold.
F5::
	TapKey("g")
	sleep 50
	TapKey("f")
	TapKey("r")
;	if ( GetKeyState("space", "p") OR GetKeyState("LAlt", "p")) { ;hold space/alt to bypass confirmation
		sleep 25
		TapKey("e")
;	}
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
	send {%key% down}
	sleep 25
	send {e up}
	send {%key% up}
	return
}

; Function that releases all the letters in the str variable
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
	ThisKey := % LTrim(A_ThisHotkey, "*~^!+#<>$")
	SetMouseDelay 25
	BlockInput On
	TapKey("ESC")
	SendEvent {click %x% %y%}
	TapKey("ESC")
	BlockInput Off
	Keywait %ThisKey%, T5
}

; Original idea by KowboyBebop of EMU Light
; QoL: Makes map key also close map
ToggleMap(){
	local ThisKey := % LTrim(A_ThisHotkey, "*~^!+#<>$")
	Send {Escape Down}
	Send {G down}
	sleep 50
	Send {Escape Up}
	Send {G up}
	KeyWait %ThisKey%, T10
}

; Interesting, saved for later
createTimer(fn, period, args*) {
    if (args.MaxIndex() != "")
        fn := Func(fn).Bind(args*)
    SetTimer % fn, % period
}

; Middle click - tap to use, hold to go back to first item.
MButtonMgr(isHold, taps, keydown){
	global UseKey
	if (taps && !isHold && keydown==-1)  ;tap
		TapKey(UseKey,25)
	if (isHold && keydown)
		TapKey("down",550)
}

z_func(isHold, taps, keydown){
	if (taps && !isHold && keydown==-1)
		TapKey("z")
	if (isHold && keydown)
		QuickUse("q")          ;2hand-Left
}

c_func(isHold, taps, keydown){
	if (taps && !isHold && keydown==-1)
		TapKey("c")
	if (isHold && keydown)
		QuickUse("LButton")    ;2hand-Right
}

f_func(isHold, taps, keydown){
	if (taps && !isHold && keydown==1) ;On keydown
		BackStep()
	if (isHold && keydown)  ;Hold, still fires backstep, but no effect in menus
		TapKey("f")
	return
}

;BackStep - usable while moving
BackStep() {
	Thread NoTimers, true  ;running timer could interrupt
	if (IsMoving()){
		ReleaseKeys("wasd")
		DisableWASD := true
		send {%RollDashKey%	up} ; in case running
		sleep 25
	}
	TapKey(RollDashKey)
	sleep 25
	if (DisableWASD){
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

; WASD gets DoubleTap ability
; While this is cool, it might kill you near cliffs, be careful
; Send WASD is bad, better to pass thru with ~
DoubleTapMoves_Roll(key, isHold, taps, keydown) {
	if (taps && !isHold && keydown==1) ;On keydown
		send {%key% down}
	if (taps==2 && !isHold && keydown==1) {  ; Double Tap keydown
		Thread NoTimers, true  ;running timer could interrupt
		if GetKeyState(RollDashKey) {
			send {%RollDashKey% up}
			sleep 25
		}
		TapKey(RollDashKey)
		Thread NoTimers, false
	}
	if (keydown < 1) ;keyup
		send {%key% up}
}

; Run on double tap hold
DoubleTapMoves_Run(key, isHold, taps, keydown) {
	if (taps==2 && !isHold && keydown==1) ; Double tap keydown
		send {%RollDashKey% down}
	if (taps==2 && keydown < 1)
		send {%RollDashKey% up}
}

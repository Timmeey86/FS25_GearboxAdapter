#Requires AutoHotkey v2.0
#SingleInstance Force
; Define keys for switches
switch1 := "3Joy2" ; Splitter
switch2 := "3Joy1" ; Range selector
gear1 := "4Joy13"
gear2 := "4Joy14"
gear3 := "4Joy15"
gear4 := "4Joy16"
gear5 := "4Joy17"
gear6 := "4Joy18"
gearR := "4Joy19"


previousState := -1
previousGearState := -1
; Monitor the key states
Loop {
	; Find out the splitter and range selector states
	
    state1 := GetKeyState(switch1, "P")
    state2 := GetKeyState(switch2, "P")

    currentState := (state2 << 1) | state1 ; Combine states into binary
	
	; Whenever the binary state changes
	if currentState != previousState {
		; Send numpad keypresses to emulate four buttons rather than two switches
		;if WinActive("ahk_exe FarmingSimulator2025Game.exe") {
			if (currentState == 0) {
				Send("{Numpad1}")
			} else if (currentState == 1) {
				Send("{Numpad2}")
			} else if (currentState == 2) {
				Send("{Numpad3}")
			} else if (currentState == 3) {
				Send("{Numpad4}")
			}
		;}
		
		Sleep 20
		
	    previousState := currentState		
	}
	
	; Do the same for gears, including detection of neutral gear
	gearState1 := GetKeyState(gear1, "P")
	gearState2 := GetKeyState(gear2, "P")
	gearState3 := GetKeyState(gear3, "P")
	gearState4 := GetKeyState(gear4, "P")
	gearState5 := GetKeyState(gear5, "P")
	gearState6 := GetKeyState(gear6, "P")
	gearStateR := GetKeyState(gearR, "P")
	
	currentGearState :=
		(gearStateR << 6)
		| (gearState6 << 5)
		| (gearState5 << 4) 
		| (gearState4 << 3)
		| (gearState3 << 2)
		| (gearState2 << 1)
		| gearState1
		
	; Whenever the binary state changes
	if currentGearState != previousGearState {
		; Send Ctrl+numpad keypresses for each gear, but also for neutral
		;if WinActive("ahk_exe FarmingSimulator2025Game.exe") {
			if (currentGearState == 0) {
				Send("^{Numpad0}") ; Neutral
			} else if (gearState1 == 1) {
				Send("^{Numpad1}")
			} else if (gearState2 == 1) {
				Send("^{Numpad2}")
			} else if (gearState3 == 1) {
				Send("^{Numpad3}")
			} else if (gearState4 == 1) {
				Send("^{Numpad4}")
			} else if (gearState5 == 1) {
				Send("^{Numpad5}")
			} else if (gearState6 == 1) {
				Send("^{Numpad6}")
			} else if (gearStateR == 1) {
				Send("^{Numpad9}") ; Reverse
			}
		;}
		
		Sleep 20
		
	    previousGearState := currentGearState		
	}

    Sleep 50
}
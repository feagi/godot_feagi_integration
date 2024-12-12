@tool
extends Resource
class_name FEAGI_EmuPredefinedInput
## Data container class used for menu sequences. Can either define a [FEAGI_EmuInput_Abstract] to represent a button to press or a time to wait

@export var emu_input: FEAGI_EmuInput_Abstract = null
@export var seconds_to_hold: float = 0.1 ## How long to hold the input, or how long to pause if no emu_input is defined

func is_delay() -> bool:
	return emu_input == null

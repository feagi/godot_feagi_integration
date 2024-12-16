@tool
extends Resource
class_name FEAGI_EmuPredefinedInputSequence
## Defines a sequence of emuInputs / wait times

@export var sequence: Array[FEAGI_EmuPredefinedInput] = []
@export var start_automatically_after_delay_of_seconds: int = -1 ## If defined as a number greater than 0, will automatically initiate on game start
@export var delay_between_steps: float = 0.1 ## The number of seconds to wait between steps, since spamming all inputs at once likely wont end well

func clear_saved_sequence() -> void:
	sequence = []

## Adds an emuInput. If at_index is -1, it will be added to the end, otherwise it will attempt to insert at a given index (pushing later index further down)
func add_emu_input(emu_input: FEAGI_EmuInput_Abstract, press_length: float, at_index: int = -1) -> Error:
	if emu_input == null:
		push_error("FEAGI: Unable to add a null EmuInput to an EmuPredefinedInputSequence! Ignoring!")
		return Error.ERR_INVALID_PARAMETER
	
	if press_length <= 0:
		push_error("FEAGI: Unable to add invalid press period! Ignoring!")
		return Error.ERR_INVALID_PARAMETER
	
	var predefined: FEAGI_EmuPredefinedInput = FEAGI_EmuPredefinedInput.new()
	predefined.emu_input = emu_input
	predefined.seconds_to_hold = press_length
	
	if at_index < -1:
		push_error("FEAGI: Unable to add EmuInput to index %d! Ignoring!" % at_index)
		return Error.ERR_INVALID_PARAMETER
	
	if at_index == -1:
		sequence.append(predefined)
		return Error.OK
	
	return sequence.insert(at_index, predefined)

## Adds a delay of given number of seconds. If at_index is -1, it will be added to the end, otherwise it will attempt to insert at a given index (pushing later index further down)
func add_delay(delay_seconds: float, at_index: int = -1) -> Error:
	
	if delay_seconds <= 0:
		push_error("FEAGI: Unable to add invalid delay period! Ignoring!")
		return Error.ERR_INVALID_PARAMETER
	
	var predefined: FEAGI_EmuPredefinedInput = FEAGI_EmuPredefinedInput.new()
	predefined.seconds_to_hold = delay_seconds
	
	if at_index < -1:
		push_error("FEAGI: Unable to add delay to index %d! Ignoring!" % at_index)
		return Error.ERR_INVALID_PARAMETER
	
	if at_index == -1:
		sequence.append(predefined)
		return Error.OK
	
	return sequence.insert(at_index, predefined)

func is_autostarting() -> bool:
	return start_automatically_after_delay_of_seconds > 0

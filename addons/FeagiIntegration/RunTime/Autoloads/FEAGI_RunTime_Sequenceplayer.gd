extends Node
class_name FEAGI_RunTime_Sequenceplayer
## Runs through a single sequence

signal started_playing_automatically(self_name: StringName)
signal done_playing(self_name: StringName)

var is_playing: bool:
	get: return _is_playing

var _sequence_name: StringName
var _sequence: FEAGI_EmuPredefinedInputSequence
var _is_playing: bool = false
var _emu_input: FEAGI_EmuInput_Abstract
var _is_pressing: bool = false

func setup(sequence_name: StringName, sequence: FEAGI_EmuPredefinedInputSequence) -> Error:
	if !sequence:
		push_error("FEAGI: Defined Sequence is invalid!")
		return Error.ERR_INVALID_PARAMETER
	if sequence_name.is_empty():
		push_error("FEAGI: Defined Sequence has no name!")
		return Error.ERR_INVALID_PARAMETER 
	if !get_parent():
		push_error("FEAGI: Unable to setup Sequence player as it is not parented to any node!")
		return Error.ERR_CANT_ACQUIRE_RESOURCE
	
	_sequence_name = sequence_name
	_sequence = sequence
	if _sequence.is_autostarting():
		_autoplay_on_load(float(_sequence.start_automatically_after_delay_of_seconds))
	
	return Error.OK
	

## ASYNC function that starts playing the given input sequence.
func play() -> void:
	if !_sequence:
		push_error("FEAGI: Sequence player has not been configured!")
	if _is_playing:
		push_error("FEAGI: Unable to start playing input sequence %s as it is already playing!" % _sequence_name)
		return
	_is_playing = true
	
	for step: FEAGI_EmuPredefinedInput in _sequence.sequence:
		if step.is_delay():
			await get_tree().create_timer(step.seconds_to_hold).timeout
			continue
		else:
			_is_pressing = true
			match(step.emu_input.get_expected_FEAGI_data_method_return_type()): # do this before process has a chance to trigger
				FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1:
					step.emu_input.runtime_setup(_0_1_press)
				# TODO other types!
					
			_emu_input = step.emu_input # this will ensure _process updates the variable
			await get_tree().create_timer(step.seconds_to_hold).timeout
			_is_pressing = false
			_emu_input.process_input() # ensure release is pressed
			_emu_input = null # block process
			step.emu_input.deinitialize()
			await get_tree().create_timer(_sequence.delay_between_steps).timeout
			
	
	_is_playing = false
	done_playing.emit(_sequence_name)

func _process(_delta: float) -> void:
	if _emu_input:
		_emu_input.process_input()
	


## ASYNC: Triggers play after waiting given time. 
func _autoplay_on_load(delay_seconds: float) -> void:
	if !get_parent():
		push_error("FEAGI: Unable to autostart Sequence player as it is not parented to any node!")
		return
	await get_tree().create_timer(delay_seconds).timeout
	started_playing_automatically.emit(_sequence_name)
	print("FEAGI: Autostarted sequence %s!" % _sequence_name)
	play()

func _0_1_press() -> float:
	return float(_is_pressing)

# TODO more processes

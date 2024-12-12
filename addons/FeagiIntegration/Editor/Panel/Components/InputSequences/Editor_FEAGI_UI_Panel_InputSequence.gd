@tool
extends MarginContainer
class_name Editor_FEAGI_UI_Panel_InputSequence

const SEQUENCE_ELEMENT_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/Editor/Panel/Components/InputSequences/Editor_FEAGI_UI_Panel_InputSequenceElement.tscn")

var sequence_name: StringName:
	get: 
		if _sequence_name_UI:
			return _sequence_name_UI.text
		return "NOT SETUP"

var _sequence_name_UI: Label
var _steps_holder: VBoxContainer
var _start_automatically_UI: CheckBox
var _start_delay_segment_UI: HBoxContainer
var _start_delay_UI: SpinBox
var _delay_between_steps_UI: SpinBox

func setup(given_sequence_name: StringName, sequence: FEAGI_EmuPredefinedInputSequence = null) -> void:
	_sequence_name_UI = $PanelContainer/VBoxContainer/SequenceName
	_steps_holder = $PanelContainer/VBoxContainer/MarginContainer/PanelContainer/StepsHolder
	_start_automatically_UI = $PanelContainer/VBoxContainer/HBoxContainer/startAutomatically
	_start_delay_segment_UI = $PanelContainer/VBoxContainer/startautosettings
	_start_delay_UI = $PanelContainer/VBoxContainer/startautosettings/SpinBox
	_delay_between_steps_UI = $PanelContainer/VBoxContainer/delaybtwm/SpinBox
	
	_sequence_name_UI.text = given_sequence_name
	
	if sequence:
		for step in sequence.sequence:
			_append_step(step)
		_start_automatically_UI.set_pressed_no_signal(sequence.is_autostarting())
		_start_delay_segment_UI.visible = sequence.is_autostarting()
		if sequence.is_autostarting():
			_start_delay_UI.value = sequence.start_automatically_after_delay_of_seconds
		_delay_between_steps_UI.value = sequence.delay_between_steps


## Returns a [FEAGI_EmuPredefinedInputSequence] pertaining to what was configred in the UI. Returns null if the sequence is not valid
func export() -> FEAGI_EmuPredefinedInputSequence:
	var output: FEAGI_EmuPredefinedInputSequence = FEAGI_EmuPredefinedInputSequence.new()
	for child in _steps_holder.get_children():
		if child is not Editor_FEAGI_UI_Panel_InputSequenceElement:
			#shouldnt be possible
			push_error("FEAGI Configurator: Invalid Input Sequence Element!")
			continue
		var step: FEAGI_EmuPredefinedInput = (child as Editor_FEAGI_UI_Panel_InputSequenceElement).export()
		if step:
			if step.emu_input:
				output.add_emu_input(step.emu_input, step.seconds_to_hold) # emulated input step
			else:
				output.add_delay(step.seconds_to_hold) # delay step
	if len(output.sequence) == 0:
		# no steps defined / valud, return null
		return null
	if _start_automatically_UI.button_pressed:
		output.start_automatically_after_delay_of_seconds = int(_start_delay_UI.value)
	output.delay_between_steps = _delay_between_steps_UI.value
	
	return output
		

func _append_step(step: FEAGI_EmuPredefinedInput = null) -> Editor_FEAGI_UI_Panel_InputSequenceElement:
	var appending: Editor_FEAGI_UI_Panel_InputSequenceElement = SEQUENCE_ELEMENT_PREFAB.instantiate()
	appending.setup(step)
	_steps_holder.add_child(appending)
	appending.request_add_sequence_element_to_index.connect(_request_adding_new_step_at_index)
	return appending

func _request_adding_new_step_at_index(index: int) -> void:
	if index >= _steps_holder.get_child_count():
		push_error("FEAGI Configurator: Unable to add input sequence step at an invalid index!")
		return
	var new_step: Editor_FEAGI_UI_Panel_InputSequenceElement = _append_step()
	_steps_holder.move_child(new_step, index)

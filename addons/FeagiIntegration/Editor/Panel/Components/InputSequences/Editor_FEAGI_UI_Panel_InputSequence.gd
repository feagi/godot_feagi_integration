@tool
extends VBoxContainer
class_name Editor_FEAGI_UI_Panel_InputSequence

const SEQUENCE_ELEMENT_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/Editor/Panel/Components/InputSequences/Editor_FEAGI_UI_Panel_InputSequenceElement.tscn")

var sequence_name: StringName:
	get: 
		if _sequence_name_UI:
			return _sequence_name_UI.text
		return "NOT SETUP"

var _sequence_name_UI: Label
var _steps_holder: VBoxContainer

func setup(given_sequence_name: StringName, sequence: FEAGI_EmuPredefinedInputSequence = null) -> void:
	_sequence_name_UI = $SequenceName
	_steps_holder = $MarginContainer/PanelContainer/StepsHolder
	
	_sequence_name_UI.text = given_sequence_name
	
	if sequence:
		for step in sequence.sequence:
			_append_step(step)

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

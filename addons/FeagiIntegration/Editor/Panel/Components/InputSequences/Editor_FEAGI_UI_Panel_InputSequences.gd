@tool
extends VBoxContainer
class_name Editor_FEAGI_UI_Panel_InputSequences

const SEQUENCE_HOLDER_UI: PackedScene = preload("res://addons/FeagiIntegration/Editor/Panel/Components/InputSequences/Editor_FEAGI_UI_Panel_InputSequence.tscn")

var _sequence_name_input: LineEdit
var _sequences_holder: VBoxContainer

func setup(sequence_string_names_and_sequences: Dictionary) -> void:
	_sequence_name_input = $HBoxContainer/title
	_sequences_holder = $MarginContainer/PanelContainer/sequences
	
	for sequence_name in sequence_string_names_and_sequences:
		_add_sequence(sequence_name, sequence_string_names_and_sequences[sequence_name])

## Exports sequences with their names as string keys and the actual [FEAGI_EmuPredefinedInputSequence] as the corresponding value
func export() -> Dictionary:
	var output: Dictionary = {}
	for child in _sequences_holder.get_children():
		var sequence_UI: Editor_FEAGI_UI_Panel_InputSequence = child as Editor_FEAGI_UI_Panel_InputSequence
		var sequence: FEAGI_EmuPredefinedInputSequence = sequence_UI.export()
		if sequence:
			output[sequence_UI.sequence_name] = sequence
	return output


## Adds a given sequence (or starts a new one). Does not do name checking
func _add_sequence(given_sequence_name: StringName, sequence: FEAGI_EmuPredefinedInputSequence = null) -> void:
	var sequence_UI: Editor_FEAGI_UI_Panel_InputSequence = SEQUENCE_HOLDER_UI.instantiate()
	_sequences_holder.add_child(sequence_UI)
	sequence_UI.setup(given_sequence_name, sequence)

func _add_sequence_button_pressed() -> Error:
	var desired_name: StringName = _sequence_name_input.text
	
	if desired_name.is_empty():
		push_error("FEAGI Configurator: Sequence name cannot be empty!")
		return Error.ERR_DOES_NOT_EXIST
	
	for child in _sequences_holder.get_children():
		var sequence_UI: Editor_FEAGI_UI_Panel_InputSequence = child as Editor_FEAGI_UI_Panel_InputSequence
		if sequence_UI.sequence_name == desired_name:
			push_error("FEAGI Configurator: Sequence with name %s already exists!" % desired_name)
			return Error.ERR_ALREADY_EXISTS
	_add_sequence(desired_name)
	_sequence_name_input.text = ""
	return Error.OK

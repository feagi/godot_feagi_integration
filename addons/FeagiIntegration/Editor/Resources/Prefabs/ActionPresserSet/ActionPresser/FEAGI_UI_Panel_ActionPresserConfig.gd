@tool
extends VBoxContainer
class_name FEAGI_UI_Panel_ActionPresserConfig
## Allows UI configuration for a single [FEAGI_Emulated_Input]

var _actions: OptionButton
var _hold: SpinBox
var _action: SpinBox
var _release: SpinBox

var _possible_actions: Array[StringName] = []

func setup(key: StringName, friendly_name: StringName, emulated_input: FEAGI_Emulated_Input = FEAGI_Emulated_Input.new()) -> void:
	name = key
	var label: Label = $HBoxContainer/friendly_name
	_actions = $HBoxContainer/OptionButton
	_hold = $CollapsiblePrefab/PanelContainer/MarginContainer/Internals/HBoxContainer/hold
	_action = $CollapsiblePrefab/PanelContainer/MarginContainer/Internals/HBoxContainer2/action_thresh
	_release = $CollapsiblePrefab/PanelContainer/MarginContainer/Internals/HBoxContainer3/release_thresh
	
	label.text = friendly_name
	
	InputMap.load_from_project_settings() # ensure we have the full info!
	_possible_actions = InputMap.get_actions()
	
	_actions.add_item("No Action")
	_actions.selected = 0
	
	for possible in _possible_actions:
		_actions.add_item(possible)
	
	_hold.value = emulated_input.action_hold_seconds
	_action.value = emulated_input.action_press_FEAGI_threshold
	_release.value = emulated_input.action_release_FEAGI_threshold
	
	if emulated_input.godot_action_name == FEAGI_Emulated_Input.NO_ACTION:
		return
	var index: int = _possible_actions.find(emulated_input.godot_action_name)
	if index != -1:
		_actions.selected = index + 1
	else:
		push_warning("FEAGI: Unable to find Input Mapping %s! Defaulting to No Action" % emulated_input.godot_action_name)

## Export the [FEAGI_Emulated_Input] represented by the values in the UI
func export() -> FEAGI_Emulated_Input:
	var output: FEAGI_Emulated_Input = FEAGI_Emulated_Input.new()
	if _actions.selected == 0:
		output.godot_action_name = FEAGI_Emulated_Input.NO_ACTION
	else:
		output.godot_action_name = _possible_actions[_actions.selected - 1]
	output.action_hold_seconds = _hold.value
	output.action_press_FEAGI_threshold = _action.value
	output.action_release_FEAGI_threshold = _action.value
	return output

func overwrite_values(action_name: StringName, hold: float, action_threshold: float, release_threshold: float) -> void:
	_hold.value = hold
	_action.value = action_threshold
	_release.value = release_threshold
	
	if action_name == FEAGI_Emulated_Input.NO_ACTION:
		_actions.selected = 0
		return
	var index: int = _possible_actions.find(action_name)
	if index != -1:
		_actions.selected = index + 1
	else:
		print("FEAGI: Unable to find input event '%s' in this project!" % action_name)



## Same as export but the [FEAGI_Emulated_Input] is the value and the key is the name of this node (the key from the setup)
func export_as_dict() -> Dictionary:
	return {name: export()}

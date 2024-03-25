"""
Copyright 2016-2024 The FEAGI Authors. All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
	http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================
"""
@tool
extends HBoxContainer
class_name FEAGIActionMapping
## TODO EDGE CASE: user selected godot action mapping, then removed it from the project settings
## TODO EDGE CASE: ensure signal name is valid

var _OPU_mapping_dropdown: OptionButton
var _X_index: SpinBox
var _input_mapping_dropdown: OptionButton
var _collapsible: FEAGIWindowCollapsible
var _press_threshold: SpinBox
var _use_strength: CheckButton
var _signal_name: LineEdit

## Called by the creator after instantiation
func setup() -> void:
	_OPU_mapping_dropdown = $VBoxContainer/HBoxContainer4/Action_Selection
	_X_index = $VBoxContainer/HBoxContainer/Index
	_input_mapping_dropdown = $VBoxContainer/HBoxContainer3/Action_Selection
	_collapsible = $VBoxContainer/CollapsiblePrefab
	_press_threshold = $VBoxContainer/CollapsiblePrefab/HBoxContainer2/threshold
	_use_strength = $VBoxContainer/CollapsiblePrefab/FeagiStrength
	_signal_name = $VBoxContainer/CollapsiblePrefab/LineEdit
	
	var opu_options: Array[StringName] = []
	opu_options.assign(FEAGIInterface.FEAGI_OPU_OPTIONS.keys()) # Why is godot so terrible at automatic type casting?
	_set_dropdown_options(opu_options, _OPU_mapping_dropdown)
	_set_dropdown_options(InputMap.get_actions(), _input_mapping_dropdown)

## Export the values as a [FEAGIActionMap]
func export() -> FEAGIActionMap:
	return  FEAGIActionMap.new(
		_OPU_mapping_dropdown.get_item_text(_OPU_mapping_dropdown.selected),
		int(_X_index.value),
		_input_mapping_dropdown.get_item_text(_input_mapping_dropdown.selected),
		_press_threshold.value,
		_use_strength.button_pressed,
		_signal_name.text
	)

## Import the values into the UI
func inport_settings(map: FEAGIActionMap) -> void:
	_attempt_set_dropdown(map.OPU_mapping_to, FEAGIInterface.FEAGI_OPU_OPTIONS.keys(), _OPU_mapping_dropdown)
	_X_index.value = map.neuron_X_index
	_attempt_set_dropdown(map.godot_action, InputMap.get_actions(), _input_mapping_dropdown)
	_press_threshold.value = map.threshold
	_use_strength.set_pressed_no_signal(map.pass_FEAGI_weight_instead_of_max)
	_signal_name.text = map.optional_signal_name

## User pressed delete button
func _user_deleted() -> void:
	queue_free()

func _set_dropdown_options(possible_options: Array[StringName], dropdown: OptionButton) -> void:
	dropdown.clear()
	for option: StringName in possible_options:
		dropdown.add_item(option)

func _attempt_set_dropdown(selection: StringName, possible_options: Array[StringName], dropdown: OptionButton) -> void:
	dropdown.clear()
	for option: StringName in possible_options:
		dropdown.add_item(option)
	var index: int = possible_options.find(selection)
	if index == -1:
		dropdown.selected = 0
		return
	dropdown.selected = index


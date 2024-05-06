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
extends RefCounted
class_name FEAGIActionMap
## Essentially just a data structure to pass mapping information

const VAR_NAMES: PackedStringArray = ["OPU_mapping_to", "neuron_X_index", "godot_action", "threshold", "pass_FEAGI_weight_instead_of_max", "optional_signal_name", "seconds_to_hold"]

var OPU_mapping_to: StringName
var neuron_X_index: int
var godot_action: StringName
var threshold: float = 0.01
var pass_FEAGI_weight_instead_of_max: bool
var optional_signal_name: StringName
var seconds_to_hold: float = 0.1

func _init(OPU_mapping_to_: StringName, neuron_X_index_: int, godot_action_: StringName, threshold_: float, pass_FEAGI_weight_instead_of_max_: bool, optional_signal_name_: StringName, hold_time_ : float) -> void:
	OPU_mapping_to = OPU_mapping_to_
	neuron_X_index = neuron_X_index_
	godot_action = godot_action_
	pass_FEAGI_weight_instead_of_max = pass_FEAGI_weight_instead_of_max_
	optional_signal_name = optional_signal_name_
	seconds_to_hold = hold_time_
	
## Returns if a Dictionary has the valid keys to be a [FEAGIActionMap]
static func is_valid_dict(verify: Dictionary) -> bool:
	for variable: StringName in VAR_NAMES:
		if !verify.has(variable):
			return false
	return true
	#TODO check types?

## Creates this object from a dictionary that was confirmed valid
static func create_from_valid_dict(dict: Dictionary) -> FEAGIActionMap:
	return FEAGIActionMap.new(
		dict["OPU_mapping_to"],
		dict["neuron_X_index"],
		dict["godot_action"],
		dict["threshold"],
		dict["pass_FEAGI_weight_instead_of_max"],
		dict["optional_signal_name"],
		dict["seconds_to_hold"]
	)

## Returns an array of mappings as a Array of Dictionarys, that can all be turned into a JSON
static func array_of_mappings_to_jsonable_array(arr: Array[FEAGIActionMap]) -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	for map: FEAGIActionMap in arr:
		output.append(map.export_as_dictionary())
	return output


static func json_array_to_array_of_mappings(input: Array) -> Array[FEAGIActionMap]:
	var output: Array[FEAGIActionMap] = []
	for input_dict: Dictionary in input:
		if FEAGIActionMap.is_valid_dict(input_dict):
			output.append(FEAGIActionMap.create_from_valid_dict(input_dict))
		else:
			push_error("Unable to read Action Map! Dict is invalid!")
	return output

## Exports the contents of this object as a json for easy json export
func export_as_dictionary() -> Dictionary:
	return {
		"OPU_mapping_to": str(OPU_mapping_to),
		"neuron_X_index": neuron_X_index,
		"godot_action": str(godot_action),
		"threshold": threshold,
		"pass_FEAGI_weight_instead_of_max": pass_FEAGI_weight_instead_of_max,
		"optional_signal_name": str(optional_signal_name),
	}

func action(activation_strength: float) -> void:
	
	#var buffer_FEAGI_motor:InputEventAction = InputEventAction.new() # Do not buffer this, a new one must be created per use
	#Input.parse_input_event(buffer_FEAGI_input)
	
	if activation_strength <  threshold:
		## no action
		Input.action_release(godot_action)
		return

	if pass_FEAGI_weight_instead_of_max:
		Input.action_press(godot_action, activation_strength)
	else:
		Input.action_press(godot_action)
	
	
	
	
	
	

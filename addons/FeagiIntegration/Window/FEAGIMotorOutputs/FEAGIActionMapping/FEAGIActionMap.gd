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

const VAR_NAMES: PackedStringArray = ["OPU_mapping_to", "neuron_X_index", "godot_action", "threshold", "pass_FEAGI_weight_instead_of_max", "optional_signal_name"]

var OPU_mapping_to: StringName
var neuron_X_index: int
var godot_action: StringName
var threshold: float = 0.5
var pass_FEAGI_weight_instead_of_max: bool
var optional_signal_name: StringName

func _init(OPU_mapping_to_: StringName, neuron_X_index_: int, godot_action_: StringName, threshold_: float, pass_FEAGI_weight_instead_of_max_: bool, optional_signal_name_: StringName) -> void:
	OPU_mapping_to = OPU_mapping_to_
	neuron_X_index = neuron_X_index_
	godot_action = godot_action_
	pass_FEAGI_weight_instead_of_max = pass_FEAGI_weight_instead_of_max_
	optional_signal_name = optional_signal_name_
	
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
	)

## Returns an array of mappings as a Array of Dictionarys, that can all be turned into a JSON
static func array_of_mappings_to_jsonable_array(arr: Array[FEAGIActionMap]) -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	for map: FEAGIActionMap in arr:
		output.append(map.export_as_dictionary())
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

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
extends ScrollContainer
class_name FEAGIMotorOutputManager

const FEAGI_OUTPUT_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/Window/FEAGIMotorOutputs/FEAGIActionMapping/FEAGIActionMapping.tscn")

var _container: VBoxContainer

func _ready() -> void:
	_container = $VBoxContainer

## Spawn an unfilled mapping element
func spawn_empty_mapping() -> FEAGIActionMapping:
	var new_mapping: FEAGIActionMapping = FEAGI_OUTPUT_PREFAB.instantiate()
	_container.add_child(new_mapping)
	new_mapping.setup()
	return new_mapping

## Spawn an unfilled mapping element and fill it with predefined values
func spawn_filled_mapping(mapping: FEAGIActionMap) -> void:
	var UI_mapping: FEAGIActionMapping = spawn_empty_mapping()
	UI_mapping.inport_settings(mapping)

## Set internals to be matching with all the input mappings
func set_filled_mappings(mappings: Array[FEAGIActionMap]) -> void:
	_delete_children()
	for mapping: FEAGIActionMap in mappings:
		spawn_filled_mapping(mapping)
	
## Export all Mapping Details as an array
func export_mappings() -> Array[FEAGIActionMap]:
	var output: Array[FEAGIActionMap] = []
	for child: Control in _container.get_children():
		if child is FEAGIActionMapping:
			output.append((child as FEAGIActionMapping).export())
	return output

func _delete_children() -> void:
	for child: Control in _container.get_children():
		child.queue_free()

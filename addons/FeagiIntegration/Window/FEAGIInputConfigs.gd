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
class_name FEAGIInputConfigs

const FEAGI_LINE_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/Window/FromFeagiLine/FromFeagiLine.tscn")

var _container: VBoxContainer

func _ready() -> void:
	_container = $VBoxContainer

## Adds a new line of a simple configuration
func add_simple_prefab(ui_action: StringName) -> void:
	if ui_action == &"":
		push_warning("FEAGIPlugin: Please select a valid UI action")
		return
	var new_line: FromFeagiLine = FEAGI_LINE_PREFAB.instantiate()
	_container.add_child(new_line)
	new_line.setup(ui_action)

## Assembles all the exports contained within as a single Array detailing what UI actions are to be triggered from what Feagi Keys and values -> [UI_map, key, val]
func export_settings() -> Array[Array]:
	var output: Array[Array] = []
	for child: Control in _container.get_children():
		if child is FromFeagiLine:
			output.append((child as FromFeagiLine).export())
	return output

## Mass spawns simple prefabs as per settings > [UI_map, key, val]
func import_settings(settings: Array) -> void:
	_delete_children()
	var ui_map: StringName
	for inner_array: Array in settings:
			var new_line: FromFeagiLine = FEAGI_LINE_PREFAB.instantiate()
			_container.add_child(new_line)
			new_line.inport_settings(inner_array)

func _delete_children() -> void:
	for child: Control in _container.get_children():
		child.queue_free()

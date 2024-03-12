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
extends EditorPlugin
class_name FEAGIPluginInit

const DOCK_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/Window/FeagiPluginDock.tscn")

var _config_window: FeagiPluginDock

func _enter_tree():
	add_autoload_singleton("FEAGI", "res://addons/FeagiIntegration/Feagi-Interface/FEAGIInterface.gd")
	print("FEAGI: Feagi Interface has been added to the project, under the name 'FEAGI'!")
	print("FEAGI: Access the FEAGI configurator through Project -> Tools -> Open FEAGI Configurator")
	add_tool_menu_item("Open FEAGI Configurator", spawn_configurator_window)


func _exit_tree():
	remove_autoload_singleton("FEAGI")
	print("FEAGI: Feagi Interface has been removed from the project!")
	remove_tool_menu_item("Open FEAGI Configurator")
	despawn_configurator_window()


func despawn_configurator_window() -> void:
	if _config_window == null:
		return
	remove_control_from_docks(_config_window)
	_config_window.queue_free()
	
	
func spawn_configurator_window() -> void:
	if _config_window != null:
		return
	_config_window = DOCK_PREFAB.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BR, _config_window)
	_config_window.setup(self)


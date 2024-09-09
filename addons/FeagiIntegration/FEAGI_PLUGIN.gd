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
class_name FEAGI_PLUGIN


const CONFIG_DIR: StringName = "res://FEAGI_config/"
const CONFIG_ENDPOINT_NAME: StringName = "endpoint.tres"
const CONFIG_GENOME_NAME: StringName = "genome_mapping.tres"
const CONFIG_GITIGNORE_TEXT: StringName = "# This gitignore is automatically generated by the Godot FEAGI Integration plugin and will be recreated if missing. The following file may contain sensitive information, hence the creation of this file. To disable this gitignore, simple comment out the files affected and save.\n" + CONFIG_ENDPOINT_NAME
const TEMPLATE_DIR: StringName = "res://addons/FeagiIntegration/Editor/Panel/Components/Devices/ConfiguratorTemplateGenerator/template.json"

const GODOT_SUPPORTED_SENSORS: PackedStringArray = ["camera"] ## All supported FEAGI Sensor devices that have Godot components available to emulate
const GODOT_SUPPORTED_MOTORS: PackedStringArray = [] ## All supported FEAGI Sensor devices that have Godot components available to emulate

const PANEL_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/Editor/Panel/FEAGI_UI_Panel.tscn")

#NOTE: Yes these return strings due to godot casting shenanigans
static func get_gitignore_path() -> String:
	return CONFIG_DIR + ".gitignore"

static func get_endpoint_path() -> String:
	return CONFIG_DIR + CONFIG_ENDPOINT_NAME

static func get_genome_mapping_path() -> String:
	return CONFIG_DIR + CONFIG_GENOME_NAME

static func confirm_config_directory() -> void:
	if not DirAccess.dir_exists_absolute(CONFIG_DIR):
		DirAccess.make_dir_absolute(CONFIG_DIR)
	if not FileAccess.file_exists(get_gitignore_path()):
		var file: FileAccess = FileAccess.open(get_gitignore_path(), FileAccess.WRITE)
		file.store_string(CONFIG_GITIGNORE_TEXT)
		file.close()


var debugger_control: FEAGI_Debug_Panel ## Accessed Externally by [FEAGIDebugger]


var _debugger: FEAGIDebugger
var _plugin_panel: FEAGI_UI_Panel

## When the plugin as a whole is enabled
func _enter_tree():
	_debugger = FEAGIDebugger.new()
	add_debugger_plugin(_debugger)
	add_autoload_singleton("FEAGI_RunTime", "res://addons/FeagiIntegration/RunTime/FEAGI_RunTime.gd")
	print("FEAGI: The Feagi Interface has been added to the project, under the name 'FEAGI_RunTime'!")
	

	print("FEAGI: Access the FEAGI configurator through Project -> Tools -> Open FEAGI Configurator")
	add_tool_menu_item("Open FEAGI Configurator", _spawn_panel)

## When the plugin as a whole is removed. Cleanup any resources
func _exit_tree():
	_debugger.close_session()
	remove_autoload_singleton("FEAGI_RunTime")
	print("FEAGI: THe Feagi Interface has been removed from the project!")
	
	remove_tool_menu_item("Open FEAGI Configurator")
	if _plugin_panel:
		_plugin_panel.queue_free()


func _spawn_panel() -> void:
	if _plugin_panel != null:
		print("FEAGI: Window is already open!")
		return
	_plugin_panel = PANEL_PREFAB.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BR, _plugin_panel)
	_plugin_panel.setup()
	_plugin_panel.tree_exited.connect(_panel_closed)


## Called when the configurator window is closed, either by the user or script.
func _panel_closed() ->void:
	remove_control_from_docks(_plugin_panel)
	_plugin_panel = null

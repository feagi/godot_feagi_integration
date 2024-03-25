@tool
# Copyright 2016-2024 The FEAGI Authors. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 	http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
extends PanelContainer
class_name FeagiPluginDock

var _enable_FEAGI: CheckButton
var _FEAGI_motor_output_manager: FEAGIMotorOutputManager
var _read_button: Button
var _FEAGI_output_config: OptionButton
var _reference_plugin_loader: FEAGIPluginInit
var _FEAGI_address_bar: LineEdit
var _FEAGI_encryption_dropdown: OptionButton
var _web_port: SpinBox
var _socket_port: SpinBox
var _metric_dropdown: FEAGIMetricDropDown
var _metric_scroll: FEAGIMetricScroll

## First thing that is ran from the plugin init script
func setup(plugin_loader: FEAGIPluginInit) -> void:
	_enable_FEAGI = $ScrollContainer/Options/ToggleFeagi/HBoxContainer/ToggleFeagi
	_FEAGI_motor_output_manager = $ScrollContainer/Options/FromFeagi/VBoxContainer/CollapsiblePrefab/FEAGIMotorOutputManager
	_read_button = $ScrollContainer/Options/Config/VBoxContainer/HBoxContainer/Read
	_FEAGI_output_config = $ScrollContainer/Options/ToFeagi/VBoxContainer/CollapsiblePrefab/OutputSettings
	_FEAGI_address_bar = $ScrollContainer/Options/AdvancedNetwork/VBoxContainer/CollapsiblePrefab/HBoxContainer/TLD
	_FEAGI_encryption_dropdown = $ScrollContainer/Options/AdvancedNetwork/VBoxContainer/CollapsiblePrefab/HBoxContainer2/TLS
	_web_port = $ScrollContainer/Options/AdvancedNetwork/VBoxContainer/CollapsiblePrefab/HBoxContainer3/Port
	_socket_port = $ScrollContainer/Options/AdvancedNetwork/VBoxContainer/CollapsiblePrefab/HBoxContainer4/Port
	_metric_dropdown = $ScrollContainer/Options/FitnessMetrics/VBoxContainer/CollapsiblePrefab/HBoxContainer/MetricType
	_metric_scroll = $ScrollContainer/Options/FitnessMetrics/VBoxContainer/CollapsiblePrefab/FEAGIMetricsScroll
	_reference_plugin_loader = plugin_loader
	update_read_button_availability()
	

## Disables / Enables the read button depending if there is a valid config to import
func update_read_button_availability() -> void:
	if !FileAccess.file_exists(FEAGIInterface.CONFIG_PATH):
		_read_button.tooltip_text = "No config file found!"
		_read_button.disabled = true
		return
	var file_json: String = FileAccess.get_file_as_string(FEAGIInterface.CONFIG_PATH)
	var json_output = JSON.parse_string(file_json) # Dict or null
	if json_output == null:
		_read_button.tooltip_text = "Unable to read config file!"
		_read_button.disabled = true
		return
	
	_read_button.tooltip_text = "Import config here"
	_read_button.disabled = false

## Writes the configuration defined in this panel to the config json
func export_config() -> void:
	var is_enabled: bool = _enable_FEAGI.button_pressed
	var feagi_output_mappings: Array[FEAGIActionMap] = _FEAGI_motor_output_manager.export_mappings()
	var automatic_send_setting: StringName = FEAGIInterface.FEAGI_AUTOMATIC_SEND.keys()[_FEAGI_output_config.selected] # Intentionally save the string to make it human readable in the json
	var domain: StringName = _FEAGI_address_bar.text
	var security: StringName = FEAGIInterface.FEAGI_TLS_SETTING.keys()[_FEAGI_encryption_dropdown.selected]
	var web_port: int = _web_port.value
	var socket_port: int = _socket_port.value
	var metrics: Array[StringName] = _metric_scroll.export_settings()
	
	_write_config_file(is_enabled, feagi_output_mappings, automatic_send_setting, domain,
	 	security, web_port, socket_port, metrics)

func import_config() -> void:
	# Read file and verification
	EditorInterface.get_resource_filesystem().scan()
	if !FileAccess.file_exists(FEAGIInterface.CONFIG_PATH):
		push_error("FEAGI: No config file found!")
		return
	var file_json: String = FileAccess.get_file_as_string(FEAGIInterface.CONFIG_PATH)
	var json_output = JSON.parse_string(file_json) # Dict or null
	if json_output == null:
		push_error("FEAGI: Unable to read config file!")
		return
	var config_dict: Dictionary = json_output as Dictionary
	
	config_dict = FEAGIInterface.validate_settings_dictionary(config_dict)
	
	## Apply settings
	_FEAGI_motor_output_manager.set_filled_mappings(FEAGIActionMap.json_array_to_array_of_mappings(config_dict["feagi_output_mappings"]))
	_enable_FEAGI.set_pressed_no_signal(config_dict["enabled"])
	var enable_index: int = int(FEAGIInterface.FEAGI_AUTOMATIC_SEND[config_dict["output"]])
	_FEAGI_output_config.selected = enable_index
	_FEAGI_address_bar.text = config_dict["FEAGI_domain"]
	_FEAGI_encryption_dropdown.selected = config_dict["encryption"].to_int()
	_web_port.value = config_dict["http_port"].to_int()
	_socket_port.value = config_dict["websocket_port"].to_int()
	var metrics: Array[StringName] = []
	metrics.assign(config_dict["metrics"])
	_metric_scroll.import_settings(metrics)
	
	print("FEAGI: Imported settings from config.json onto the configuration panel successfully!")

func _add_metric() -> void:
	if _metric_dropdown.selected == -1:
		return # Don't bother adding anything if user selected nothing
	_metric_scroll.add_metric(_metric_dropdown.get_selected_metric())
	_metric_dropdown.update_list_availability()
	_metric_dropdown.selected = -1

## Writes the defined configuration to the config json file, overwritting the previous
func _write_config_file(feagi_enabled: bool, feagi_output_mappings: Array[FEAGIActionMap], output_setting: StringName,
domain: StringName, encryption_setting: StringName, web_port: int, socket_port: int, metrics: Array[StringName]) -> void:
	var to_write: Dictionary = {}
	to_write["enabled"] = feagi_enabled
	to_write["feagi_output_mappings"] = FEAGIActionMap.array_of_mappings_to_jsonable_array(feagi_output_mappings)
	to_write["output"] = str(output_setting)
	to_write["FEAGI_domain"] = str(domain)
	to_write["encryption"] = str(encryption_setting)
	to_write["http_port"] = str(web_port)
	to_write["websocket_port"] = str(socket_port)
	to_write["metrics"] = metrics
	
	var json: StringName =  JSON.stringify(to_write)
	
	var config_file: FileAccess
	if FileAccess.file_exists(FEAGIInterface.CONFIG_PATH):
		print("FEAGI: FEAGI Config already exists. Ovrewriting...")
		DirAccess.remove_absolute(FEAGIInterface.CONFIG_PATH)
	config_file = FileAccess.open(FEAGIInterface.CONFIG_PATH, FileAccess.WRITE_READ)
	config_file.store_string(json)
	config_file.close()
	print("FEAGI: Exported FEAGI Config!")
	EditorInterface.get_resource_filesystem().scan()
	update_read_button_availability()

func _close_configurator() -> void:
	_reference_plugin_loader.despawn_configurator_window()

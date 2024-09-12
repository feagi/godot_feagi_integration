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
extends VBoxContainer
class_name FEAGI_UI_Panel_AgentSettings

var FEAGI_enabled: bool:
	get: 
		if _enable_FEAGI: 
			return _enable_FEAGI.button_pressed
		return false
	set(v):
		if _enable_FEAGI: 
			_enable_FEAGI.button_pressed = v
		if _network_settings:
			toggle_showing_network_settings(v)

var debug_enabled: bool:
	get: 
		if _enable_debug: 
			return _enable_debug.button_pressed
		return false
	set(v):
		if _enable_debug: 
			_enable_debug.button_pressed = v

var refresh_rate: float:
	get:
		if _WS_port:
			return 1.0 / float(_refresh_rate.value)
		return -1.0
	set(v):
		if _WS_port:
			int(1.0 / v)

var _enable_FEAGI: CheckBox
# TODO Magic URL
var _network_settings: FEAGI_UI_Prefab_Collapsible
var _FEAGI_endpoint: LineEdit
var _connector_endpoint: LineEdit
var _API_port: SpinBox
var _WS_port: SpinBox
var _enable_debug: CheckBox
var _refresh_rate: SpinBox

## Called from the panel due to execution order
func initialize_references() -> void:
	_enable_FEAGI = $EnableFEAGI/EnableFEAGI
	_network_settings = $FEAGINetworkSettings/Manual_Connection_Settings
	_FEAGI_endpoint = $FEAGINetworkSettings/Manual_Connection_Settings/PanelContainer/MarginContainer/Internals/FEAGI_Endpoint
	_connector_endpoint = $FEAGINetworkSettings/Manual_Connection_Settings/PanelContainer/MarginContainer/Internals/Connector_Endpoint
	_API_port = $FEAGINetworkSettings/Manual_Connection_Settings/PanelContainer/MarginContainer/Internals/API_Port
	_WS_port = $FEAGINetworkSettings/Manual_Connection_Settings/PanelContainer/MarginContainer/Internals/WS_Port
	_enable_debug = $EnableDebug/EnableDebug
	_refresh_rate = $RefreshRate/RefreshRate

func toggle_showing_network_settings(is_visible: bool) -> void:
	_network_settings.toggle_visibility(is_visible)

## Exports endpoint resource
func export_endpoint() -> FEAGI_Resource_Endpoint:
	return FEAGI_Resource_Endpoint.new() #TODO replace

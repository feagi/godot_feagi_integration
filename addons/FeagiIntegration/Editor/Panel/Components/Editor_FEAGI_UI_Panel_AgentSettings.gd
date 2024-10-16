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
class_name Editor_FEAGI_UI_Panel_AgentSettings

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

var refresh_rate: int:
	get:
		if _refresh_rate:
			return _refresh_rate.value
		push_warning("FEAGI: Unable to access refresh rate! Disabling!")
		return 0
	set(v):
		if _refresh_rate:
			_refresh_rate.value = v

var _enable_FEAGI: CheckBox
var _magic_URL: LineEdit
var _network_settings: FEAGI_UI_Prefab_Collapsible
var _FEAGI_endpoint: LineEdit
var _connector_endpoint: LineEdit
var _API_port: SpinBox
var _WS_port: SpinBox
var _enable_debug: CheckBox
var _refresh_rate: SpinBox
var _SSL: CheckBox
var _cached_endpoint: FEAGI_Resource_Endpoint = FEAGI_Resource_Endpoint.new()
var _processing_magic_link: bool = false

## Called from the panel due to execution order
func initialize_references() -> void:
	_enable_FEAGI = $EnableFEAGI/EnableFEAGI
	_magic_URL = $FEAGINetworkSettings/MagicURL/URL
	_network_settings = $FEAGINetworkSettings/Manual_Connection_Settings
	_FEAGI_endpoint = $FEAGINetworkSettings/Manual_Connection_Settings/PanelContainer/MarginContainer/Internals/HBoxContainer2/FEAGI_Endpoint
	_connector_endpoint = $FEAGINetworkSettings/Manual_Connection_Settings/PanelContainer/MarginContainer/Internals/HBoxContainer3/Connector_Endpoint
	_API_port = $FEAGINetworkSettings/Manual_Connection_Settings/PanelContainer/MarginContainer/Internals/HBoxContainer4/API_Port
	_WS_port = $FEAGINetworkSettings/Manual_Connection_Settings/PanelContainer/MarginContainer/Internals/HBoxContainer5/WS_Port
	_enable_debug = $EnableDebug/EnableDebug
	_refresh_rate = $RefreshRate/RefreshRate
	_SSL = $FEAGINetworkSettings/Manual_Connection_Settings/PanelContainer/MarginContainer/Internals/HBoxContainer/SSL

func update_UI_from_cached_endpoint() -> void:
	_magic_URL.text = _cached_endpoint.magic_link_full
	_FEAGI_endpoint.text = _cached_endpoint.FEAGI_TLD
	_connector_endpoint.text = _cached_endpoint.connector_TLD
	_API_port.value = _cached_endpoint.FEAGI_API_port
	_WS_port.value = _cached_endpoint.connector_ws_port
	_SSL.button_pressed = _cached_endpoint.is_using_SSL


func parse_FEAGI_URL(feagi_URL: StringName) -> void:
	_cached_endpoint.parse_full_FEAGI_URL(feagi_URL)
	update_UI_from_cached_endpoint()

func parse_connector_URL(connector_URL: StringName) -> void:
	_cached_endpoint.parse_full_connector_URL(connector_URL)
	update_UI_from_cached_endpoint()

func toggle_showing_network_settings(is_visible: bool) -> void:
	_network_settings.toggle_visibility(is_visible)

## Exports endpoint resource
func export_endpoint() -> FEAGI_Resource_Endpoint:
	return _cached_endpoint
	
func import_endpoint(endpoint: FEAGI_Resource_Endpoint) -> void:
	_cached_endpoint = endpoint
	update_UI_from_cached_endpoint()

## ASYNC Attempts to load FEAGI endpoint information from NRS and if succeeds, overwrites local connection information with it
func load_endpoints_from_magic_link() -> void:
	if _processing_magic_link:
		return # avoid spam clicks
	_processing_magic_link = true
	_cached_endpoint.magic_link_full = _magic_URL.text
	await _cached_endpoint.update_internal_vars_from_magic_link(self)
	update_UI_from_cached_endpoint()
	_processing_magic_link = false
	
	

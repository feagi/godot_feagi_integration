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

extends Node
class_name FEAGIInterface
## Autoladed interface to access FEAGI from the game

const CONFIG_PATH: StringName = "res://addons/FeagiIntegration/config.json"

enum FEAGI_AUTOMATIC_SEND {
	NO_AUTOMATIC_SENDING,
	AUTOMATIC_SEND_WHOLE_VIEWPORT,
	#TODO add more!
}

enum FEAGI_TLS_SETTING {
	NO_ENCRYPTION,
	BOTH_TLS_ENCRYPTED
}

## Why does Godot not let me do this without this custom thing?
enum EXPECTED_TYPE {
	BOOL,
	INT,
	FLOAT,
	PERCENTAGE # just a float but within the range of 0 - 100
}

# formatted as {key_name: [friendly name, expected type]}
const METRIC_MAPPINGS: Dictionary = {
	"time_left": ["Time remaining", EXPECTED_TYPE.FLOAT],
	"time_spent": ["Time spent", EXPECTED_TYPE.FLOAT],
	"has_won": ["Has the agent succeeded", EXPECTED_TYPE.BOOL],
	"points_maximize": ["Points the agent was trying to get a high score on", EXPECTED_TYPE.FLOAT],
	"points_minimize": ["Points the agent was trying to get a high score on (like with golf)", EXPECTED_TYPE.FLOAT],
	"life_percentage": ["Percentage of life / battery / health remaining", EXPECTED_TYPE.PERCENTAGE],
	"success_count": ["Number of times won", EXPECTED_TYPE.INT],
	"failure_count": ["Number of times lost", EXPECTED_TYPE.INT],
	"terminated": ["If the agent has 'died'", EXPECTED_TYPE.BOOL],
}

signal socket_retrieved_data(data: Signal) ## FEAGI Websocket retrieved data, useful for custom integrations

var _is_socket_ready: bool = false
var _automated_sending_mode: FEAGI_AUTOMATIC_SEND = FEAGI_AUTOMATIC_SEND.NO_AUTOMATIC_SENDING
var _socket: FEAGISocket
var _network_bootstrap: FEAGINetworkBootStrap
var _feagi_triggers_from_websocket: Dictionary # Feagi key -> value -> ui_action
var _ui_action_pressed: Dictionary # ui_action: is_pressed(bool)
var _viewport_ref: Viewport

# Keep these buffers non-local to minimize allocation / deallocation penalties
var _buffer_string: String
var _buffer_data: Variant
var _buffer_image: Image
var _buffer_image_raw: PackedByteArray


func _init():
	# Halt any sort of processing on this node
	set_process(false)
	set_physics_process(false)

func _ready() -> void:
	if !FileAccess.file_exists(CONFIG_PATH):
		push_error("FEAGI: No Config located, not starting FEAGI integration!")
		return
	
	var file_json: String = FileAccess.get_file_as_string(CONFIG_PATH)
	var json_output = JSON.parse_string(file_json) # Dict or null
	if json_output == null:
		push_error("FEAGI: Unable to read config file for FEAGI, not starting FEAGI integration!")
		return
	var config_dict: Dictionary = json_output as Dictionary
	
	if !is_settings_dict_valid(config_dict):
		push_error("FEAGI: Not starting FEAGI integration!")
		return
	
	if !config_dict["enabled"]:
		print("FEAGI: FEAGI disabled, not starting....")
		return
	
	print("FEAGI: FEAGI Integration is enabled, preparing to initialize!")
	
	# import config for UI mapping, and UI pressed dict
	var config_mappings: Array = config_dict["input_mappings"]
	for mapping in config_mappings: # [UI_map, key, val]
		if mapping[1] not in _feagi_triggers_from_websocket.keys():
			_feagi_triggers_from_websocket[mapping[1]] = {}
		_feagi_triggers_from_websocket[mapping[1]][mapping[2]] = mapping[0]
		_ui_action_pressed[mapping[0]] = false
	
	# check automatic sending config,
	var raw_send_config: String = config_dict["output"]
	_automated_sending_mode = FEAGI_AUTOMATIC_SEND[raw_send_config]
	print("FEAGI: FEAGI automated sending mode is set to: %s" % raw_send_config)
	
	# Get Network info
	var domain: StringName = config_dict["FEAGI_domain"]
	var encryption_setting: FEAGI_TLS_SETTING = FEAGI_TLS_SETTING[str(config_dict["encryption"])]
	var web_port: int = config_dict["http_port"].to_int()
	var socket_port: int = config_dict["websocket_port"].to_int()
	var web_tls: StringName = ""
	var socket_tls: StringName = ""
	match encryption_setting:
		FEAGI_TLS_SETTING.NO_ENCRYPTION:
			web_tls = "http://"
			socket_tls = "ws://"
		FEAGI_TLS_SETTING.BOTH_TLS_ENCRYPTED:
			web_tls = "https://"
			socket_tls = "wss://"
	
	# Initialize Bootstrap to get connection info
	_network_bootstrap = FEAGINetworkBootStrap.new()
	_network_bootstrap.base_network_initialization_completed.connect(_network_bootstrap_complete)
	_network_bootstrap.init_network(domain, web_tls, socket_tls, web_port, socket_port)


func _process(_delta: float) -> void:
	if !_is_socket_ready:
		return
	_socket.socket_status_poll() # must be done to keep socket clean

func _physics_process(_delta: float) -> void:
	
	match(_automated_sending_mode):
		FEAGI_AUTOMATIC_SEND.AUTOMATIC_SEND_WHOLE_VIEWPORT:
			_buffer_image = _viewport_ref.get_texture().get_image()
			_buffer_image.convert(Image.FORMAT_RGB8)
			_buffer_image.resize(128, 128, Image.INTERPOLATE_NEAREST)
			_buffer_image_raw = _buffer_image.get_data()
			_socket.websocket_send_bytes(_buffer_image_raw)

## Used to check if the loaded config file has all required keys
static func is_settings_dict_valid(dict: Dictionary) -> bool:
	for checking_key: String in ["input_mappings", "enabled", "output", "FEAGI_domain", "encryption", "http_port", "websocket_port"]:
		if !(checking_key in dict.keys()):
			push_error("FEAGI: Config file invalid! Missing key %s!" % checking_key)
			return false
	return true

## Send text data to FEAGI
func send_to_FEAGI_text(data: String) -> void:
	if !_is_socket_ready:
		push_warning("FEAGI: Cannot send any data to FEAGI when the interface is disabled!")
	_socket.websocket_send_text(data)

## Send raw byte data to FEAGI
func send_to_FEAGI_raw(data: PackedByteArray) -> void:
	if !_is_socket_ready:
		push_warning("FEAGI: Cannot send any data to FEAGI when the interface is disabled!")
	_socket.websocket_send_bytes(data)

func _network_bootstrap_complete() -> void:
	print("FEAGI: Connecting to FEAGI Websocket at '%s'..." % _network_bootstrap.feagi_socket_address)
	_viewport_ref = get_viewport()
	_network_bootstrap.base_network_initialization_completed.disconnect(_network_bootstrap_complete)
	_socket = FEAGISocket.new(_network_bootstrap.feagi_socket_address)
	_socket.socket_state_changed.connect(_socket_change_state)
	_socket.FEAGI_returned_data.connect(_socket_recieved_data)
	set_process(true)
	if _automated_sending_mode in [FEAGI_AUTOMATIC_SEND.AUTOMATIC_SEND_WHOLE_VIEWPORT]: # add more as needed
		set_physics_process(true)
	_is_socket_ready = true
	pass

func _socket_recieved_data(data: PackedByteArray) -> void:
	socket_retrieved_data.emit(data)
	_buffer_string = data.get_string_from_utf8()
	if _buffer_string == "":
		# FEAGI sends empty strings when nothing is happening. Ignore this
		return
	_buffer_string = _buffer_string.replace("'", "\"") # funny json shenanigans
	_buffer_data = JSON.parse_string(_buffer_string)
	if _buffer_data == null or !(_buffer_data is Dictionary):
		push_error("FEAGI: FEAGI did not return valid data!")
		return
	_parse_Feagi_data_as_inputs(_buffer_data as Dictionary)
	

## Parse through the recieved dict from FEAGI, and if matching patterns defined by the config, fire the defined action
func _parse_Feagi_data_as_inputs(feagi_input: Dictionary) -> void:
	# reset UI actions
	for ui_action: String in _ui_action_pressed.keys():
		_ui_action_pressed[ui_action] = false
	
	# Check which keys FEAGI Pressed
	for feagi_key in feagi_input.keys():
		if feagi_key not in _feagi_triggers_from_websocket.keys():
			continue
		

		for feagi_key_second in feagi_input[feagi_key].keys():
			
			if feagi_key_second in _feagi_triggers_from_websocket[feagi_key].keys():
				print("FEAGI: FEAGI pressed input: %s" % _feagi_triggers_from_websocket[feagi_key][feagi_key_second])
				_ui_action_pressed[_feagi_triggers_from_websocket[feagi_key][feagi_key_second]] = true
				#_bufferFEAGI_input.action = _feagi_triggers_from_websocket[feagi_key][feagi_key_second]
				#parse_input_event
				#Input.parse_input_event(_bufferFEAGI_input)
				#Input.action_press(_feagi_triggers_from_websocket[feagi_key][feagi_key_second])
		continue
	
	
	# Press all keys that FEAGI pressed (and release the others)
	#NOTE: We make use of both 'action_press' and 'parse_input_event' to account for odd technecalities on how godot handles input
	#WARNING: Running Godot in headless mode may result in these input events not working due to an engine bug
	#TODO: Workaround for above involes using (relevant_viewport).
	for ui_action: String in _ui_action_pressed.keys():
		var buffer_FEAGI_input:InputEventAction = InputEventAction.new() # Do not buffer this, a new one must be created per use
		buffer_FEAGI_input.action = ui_action
		if _ui_action_pressed[ui_action]:
			buffer_FEAGI_input.pressed = true
			Input.action_press(ui_action)
		else:
			buffer_FEAGI_input.pressed = false
			Input.action_release(ui_action)
		Input.parse_input_event(buffer_FEAGI_input)
			

func _socket_change_state(state: WebSocketPeer.State) -> void:
	if state == WebSocketPeer.STATE_CLOSED or state == WebSocketPeer.STATE_CLOSING:
		push_warning("FEAGI: FEAGI Socket closed, stopping FEAGI integration")
		print("FEAGI: FEAGI Socket closed, stopping FEAGI integration")
		set_process(false)
		set_physics_process(false)
		_is_socket_ready = false

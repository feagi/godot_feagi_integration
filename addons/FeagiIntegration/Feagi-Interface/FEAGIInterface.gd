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

#region definitions and vars
extends Node
class_name FEAGIInterface
## Autoladed interface to access FEAGI from the game

const CONFIG_PATH: StringName = "res://FEAGI_config.json"
const FEAGIHTTP_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/Feagi-Interface/FEAGIHTTP.tscn")
const METRIC_PATH: StringName = "/v1/training/game_stats"
const DELETE_METRIC_PATH: StringName = "/v1/training/reset_game_stats"

enum FEAGI_AUTOMATIC_SEND {
	NO_AUTOMATIC_SENDING,
	AUTOMATIC_SEND_WHOLE_VIEWPORT,
	#TODO add more!
}

enum FEAGI_OPU_OPTIONS {
	MOTION_CONTROL,
	MOTOR,
	MISC
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

const DEFAULT_CONFIGS: Dictionary = {
	"feagi_output_mappings" = [],
	"enabled" = false,
	"output" = "NO_AUTOMATIC_SENDING", # from enum FEAGI_AUTOMATIC_SEND
	"FEAGI_domain" = "127.0.0.1",
	"encryption" = "NO_ENCRYPTION",
	"http_port" = 8000,
	"websocket_port" = 9055,
	"metrics" = []
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
signal feagi_connection_established() ## FEAGI connection has been established!
signal feagi_connection_lost() ## The websocket connection to Feagi has been lost!

#endregion

#region start

var _is_socket_ready: bool = false
var _automated_sending_mode: FEAGI_AUTOMATIC_SEND = FEAGI_AUTOMATIC_SEND.NO_AUTOMATIC_SENDING
var _socket: FEAGISocket
var _network_bootstrap: FEAGINetworkBootStrap
var _feagi_motor_mappings: Dictionary # mapped by opu + str(neuron_ID) -> [FEAGIActionMap]
var _feagi_required_metrics: Dictionary # required metric str key -> EXPECTED_TYPE
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
		push_error("FEAGI: No Config located at 'res://FEAGI_config.json', not starting FEAGI integration!")
		return
	
	var file_json: String = FileAccess.get_file_as_string(CONFIG_PATH)
	var json_output = JSON.parse_string(file_json) # Dict or null
	if json_output == null:
		push_error("FEAGI: Unable to read config file for FEAGI at 'res://FEAGI_config.json', not starting FEAGI integration!")
		return
	var config_dict: Dictionary = json_output as Dictionary
	
	config_dict = validate_settings_dictionary(config_dict)
	
	if !config_dict["enabled"]:
		print("FEAGI: FEAGI disabled, not starting....")
		return
	
	print("FEAGI: FEAGI Integration is enabled, preparing to initialize!")
	
	# import config for UI motor mapping, and UI pressed dict
	var raw_config_mappings: Array = config_dict["feagi_output_mappings"]
	for raw_mapping: Dictionary in raw_config_mappings:
		if !FEAGIActionMap.is_valid_dict(raw_mapping):
			push_warning("FEAGI: Unable to read motor mapping information from configuration!")
			continue
		var map: FEAGIActionMap = FEAGIActionMap.create_from_valid_dict(raw_mapping)
		_feagi_motor_mappings[map.OPU_mapping_to.to_lower() + str(map.neuron_X_index)] = map
	
	# check and set automatic sending config,
	var raw_send_config: String = config_dict["output"]
	_automated_sending_mode = FEAGI_AUTOMATIC_SEND[raw_send_config]
	print("FEAGI: FEAGI automated sending mode is set to: %s" % raw_send_config)
	
	# set requirements for metrics method
	var metric_keys: Array = config_dict["metrics"]
	for key: String in metric_keys:
		_feagi_required_metrics[key] = METRIC_MAPPINGS[key][1]
	
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

## Used to check if the loaded config file has all required keys , otherwise loads defaults
static func validate_settings_dictionary(checking_config: Dictionary) -> Dictionary:
	# Two loops is not particuarly efficient. Too Bad!
	for input_key: String in checking_config:
		if input_key not in DEFAULT_CONFIGS.keys():
			push_warning("Unknown configuration key $s! Ignoring..." % input_key)
	
	var to_append: Dictionary = {}
	
	for confirm_key in DEFAULT_CONFIGS.keys():
		if confirm_key not in checking_config.keys():
			push_warning("Missing configuration key '%s'! Loading default value...." % confirm_key)
			to_append[confirm_key] = DEFAULT_CONFIGS[confirm_key]
	
	checking_config.merge(to_append)
	return checking_config
		

#endregion

#region for_user_use

## Send metrics using the keys specified in the 'Fitness Metrics' to FEAGI
func send_metrics_to_FEAGI(stats: Dictionary) -> void:
	if !_is_socket_ready:
		push_warning("FEAGI: Cannot interact with FEAGI when the interface is disabled!")
	for input_key in stats.keys():
		if input_key not in METRIC_MAPPINGS.keys():
			push_error("FEAGI: Invalid key %s in input stats dict! Not sending!" % input_key)
			return
		if _get_value_type(stats[input_key][1]) != typeof(stats[input_key]):
			push_error("FEAGI: Key %s is of invalid type!!" % input_key)
			return
	
	var http_send: FEAGIHTTP = FEAGIHTTP_PREFAB.instantiate()
	add_child(http_send)
	http_send.send_POST_request(_network_bootstrap.feagi_root_web_address, _network_bootstrap.DEF_HEADERSTOUSE, METRIC_PATH, JSON.stringify(stats))

## Tell FEAGI to delete ALL of its metrics
func delete_metrics_from_FEAGI() -> void:
	if !_is_socket_ready:
		push_warning("FEAGI: Cannot interact with FEAGI when the interface is disabled!")
	var http_send: FEAGIHTTP = FEAGIHTTP_PREFAB.instantiate()
	add_child(http_send)
	http_send.send_DELETE_request(_network_bootstrap.feagi_root_web_address, _network_bootstrap.DEF_HEADERSTOUSE, DELETE_METRIC_PATH, JSON.stringify({}))

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

#endregion

#region Internals
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

# Keep these buffers non-local to minimize allocation / deallocation penalties
var _buffer_unpressed_motor_mapping_names: Array
var _buffer_motor_search_string: StringName
var _buffer_motor_search_index: int
## Parse through the recieved dict from FEAGI, and if matching patterns defined by the config, fire the defined action
func _parse_Feagi_data_as_inputs(feagi_input: Dictionary) -> void:
	_buffer_unpressed_motor_mapping_names = _feagi_motor_mappings.keys()
	
	# Check which keys FEAGI Pressed
	for from_OPU: StringName in feagi_input.keys():
		for neuron_index: String in feagi_input[from_OPU].keys(): # For whatever reason, the neuron indexes sent from the controller are strings
			_buffer_motor_search_string = from_OPU + neuron_index
			_buffer_motor_search_index = _buffer_unpressed_motor_mapping_names.find(_buffer_motor_search_string)
			if _buffer_motor_search_index != -1:
				print("FEAGI: FEAGI pressed input: %s" % _feagi_motor_mappings[_buffer_motor_search_string].godot_action)
				_feagi_motor_mappings[_buffer_motor_search_string].action(feagi_input[from_OPU][neuron_index], self)
				_buffer_unpressed_motor_mapping_names.remove_at(_buffer_motor_search_index)
	
	# for all keys unpressed, action with 0 strength
	for unpressed_mapping_name: StringName in _buffer_unpressed_motor_mapping_names:
		_feagi_motor_mappings[unpressed_mapping_name].action(0, self)

func _socket_change_state(state: WebSocketPeer.State) -> void:
	if state == WebSocketPeer.STATE_OPEN:
		print("FEAGI: FEAGI Socker Connected!")
		feagi_connection_established.emit()
		return
	if state == WebSocketPeer.STATE_CLOSED or state == WebSocketPeer.STATE_CLOSING:
		push_warning("FEAGI: FEAGI Socket closed, stopping FEAGI integration")
		print("FEAGI: FEAGI Socket closed, stopping FEAGI integration")
		set_process(false)
		set_physics_process(false)
		_is_socket_ready = false
		feagi_connection_lost.emit()

func _get_value_type(custom_expected: EXPECTED_TYPE) -> Variant.Type:
	match(custom_expected):
		EXPECTED_TYPE.BOOL:
			return TYPE_BOOL
		EXPECTED_TYPE.INT:
			return TYPE_INT
		_:
			return TYPE_FLOAT


#endregion

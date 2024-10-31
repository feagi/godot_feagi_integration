extends Node
class_name FEAGI_RunTime_FEAGIInterface
## Handles the actual data transfer with FEAGI and the Godot Games Connector

enum MODE {NONE, POSTMESSAGE, WEBSOCKET}

signal interface_closed()
signal interface_recieved_motor_data()

var connection_active: bool:
	get: return _connection_active

var mode: MODE:
	get: return _mode

var _connection_active: bool  = false
var _mode: MODE = MODE.NONE

var _WS: FEAGI_Networking_WS = null
var _PM: FEAGI_RunTime_FakeFEAGIInterface = null

var _cached_FEAGI_sensors: Array[FEAGI_IOConnector_Sensor_Base]
var _cached_FEAGI_motors: Array[FEAGI_IOConnector_Motor_Base]

var _FEAGI_sending_dict_structure: Dictionary ## Cached dict
var _FEAGI_receiving_dict_structure: Dictionary ## Cached dict

func _enter_tree() -> void:
	name = "FEAGI Interface"

func _process(_delta: float) -> void:
	
	if !_WS:
		return
	_WS.process_WS()

## ASYNC Initialize Websocket
func setup_websocket(full_connector_WS_address: StringName) -> bool:
	_WS = FEAGI_Networking_WS.new()
	var result: bool = await _WS.setup_websocket(full_connector_WS_address)
	if result:
		if !_WS.recieved_bytes.is_connected(_on_motor_receive):
			_WS.recieved_bytes.connect(_on_motor_receive)
		set_process(true)
		_connection_active = true
		_mode = MODE.WEBSOCKET
		return true
	set_process(false)
	_WS = null
	connection_active = false
	_mode = MODE.NONE
	return false

## Setup PostMessage interface
func setup_postmessage() -> bool:
	if !FEAGI_JS.is_web_build(): # prevent from calling if not web build
		_PM = null
		connection_active = false
		_mode = MODE.NONE
		return false
	_PM = FEAGI_RunTime_FakeFEAGIInterface.new()
	if !_PM.recieved_bytes.is_connected(_on_motor_receive):
		_PM.recieved_bytes.connect(_on_motor_receive)
	connection_active = true
	_mode = MODE.POSTMESSAGE
	return true

## ASYNC function that returns true if feagis healthcheck returns at the given address
func ping_feagi_available(full_feagi_address: StringName) -> bool:
	var health_check_add: StringName = full_feagi_address + "/v1/system/health_check"
	var worker: FEAGIHTTP = FEAGIHTTP.new()
	worker.name = "health_check"
	add_child(worker)
	worker.send_GET_request(full_feagi_address, "/v1/system/health_check")
	var response: Array = await worker.FEAGI_call_complete
	if len(response) != 2:
		return false
	return response[0] != 0



## Send the dicts used to define the device listings
func set_cached_device_dicts(sensors: Dictionary, motors: Dictionary) -> void:
	_cached_FEAGI_sensors.assign(sensors.values())
	_cached_FEAGI_motors.assign(motors.values())
	
	# setup dictionary layout of reciving and sending dicts so we dont constantly have to reformat them
	for sensor: FEAGI_IOConnector_Sensor_Base in sensors.values():
		if sensor.get_device_type() not in _FEAGI_sending_dict_structure:
			_FEAGI_sending_dict_structure[sensor.get_device_type()] = {}
		if sensor.device_ID not in _FEAGI_sending_dict_structure[sensor.get_device_type()]:
			_FEAGI_sending_dict_structure[sensor.get_device_type()][str(sensor.device_ID)] = PackedByteArray()
	
	for motor: FEAGI_IOConnector_Motor_Base in motors.values():
		if motor.get_device_type() not in _FEAGI_receiving_dict_structure:
			_FEAGI_receiving_dict_structure[ motor.get_device_type()] = {}
		if motor.device_ID not in _FEAGI_receiving_dict_structure[motor.get_device_type()]:
			_FEAGI_receiving_dict_structure[motor.get_device_type()][str(motor.device_ID)] = PackedByteArray()


## ASYNC initialize connector with the configurator json
func send_final_configurator_JSON(configurator_JSON: StringName) -> void:
	if _mode != MODE.WEBSOCKET:
		push_error("FEAGI: Unable to send ")
		return
	_WS.send_over_socket(configurator_JSON.to_ascii_buffer())
	await get_tree().create_timer(0.2).timeout # await connector to process. Yes this is CANCER

## Called when we need to send sensory data to FEAGI
func on_sensor_tick() -> void:
	if _mode == MODE.NONE:
		push_error("FEAGI: Cannot send data without an open interfac!")
		return

	#for sensor in _cached_FEAGI_sensors: NOTE: This comment of code directly translates bytes to string. THis was an attempt to translate what we were doing to the current standard but didnt work. Still keeping this here as a template. for now we will use a worse performing implementation that works with the current JSON nonsense we have
	#	_FEAGI_sending_dict_structure[sensor.get_device_type()][sensor.device_ID] = sensor.get_cached_data_as_byte_array() # Retrieves cached sensor byte data. Make sure this was recently updated!
	for sensor in _cached_FEAGI_sensors:
		if sensor.get_device_type() == "camera":
			_FEAGI_sending_dict_structure[sensor.get_device_type()][str(sensor.device_ID)] = sensor.get_cached_data_as_byte_array()
			continue
		if sensor.get_device_type() == "proximity":
			_FEAGI_sending_dict_structure[sensor.get_device_type()][str(sensor.device_ID)] =  (sensor as FEAGI_IOConnector_Sensor_Proximity).get_cached_data_as_float()
			continue
		if sensor.get_device_type() == "gyro" or sensor.get_device_type() == "accelerometer":
			var temp: Vector3 = _parse_bytes_as_vector3(sensor.get_cached_data_as_byte_array())
			_FEAGI_sending_dict_structure[sensor.get_device_type()][str(sensor.device_ID)] = [temp.x, temp.y, temp.z]
		# RIP frames
	
	if _mode == MODE.WEBSOCKET:
		_WS.send_over_socket(str(_FEAGI_sending_dict_structure).to_ascii_buffer())
		return
	if _mode == MODE.POSTMESSAGE:
		push_error("FEAGI: Sending data over PostMessage is not supported!")
		# TODO support sending data!
		return

func _on_motor_receive(raw_data: PackedByteArray) -> void:
	## NOTE For now we are doing the HACK method with json. Yes this will be updated in a future date
	# yes this is very slow. We will be replacing this all soon though, this is justy for demonstation
	# CANCER CANCER CANCER
	var some_value
	var device_incoming_data: PackedByteArray
	var incoming_dict: Dictionary = JSON.parse_string(raw_data.get_string_from_utf8())
	for motor in _cached_FEAGI_motors:
		if motor.get_device_type() in incoming_dict:
			if str(motor.device_ID) in incoming_dict[motor.get_device_type()]:
				some_value = incoming_dict[motor.get_device_type()][str(motor.device_ID)]
				if some_value is float or some_value is int:
					device_incoming_data.resize(4)
					device_incoming_data.encode_float(0, some_value)
				if some_value is Dictionary:
					# HACK right now we know the only type of dictionary is motion control. hard coding...
					var transpose: FEAGI_Data_MotionControl = FEAGI_Data_MotionControl.create_from_FEAGI_JSON(some_value)
					device_incoming_data = transpose.to_bytes()
					
			else:
				device_incoming_data = motor.retrieve_zero_value_byte_array()
		else:
			device_incoming_data = motor.retrieve_zero_value_byte_array()
		motor.update_cache_with_latest_FEAGI_data(device_incoming_data)
	interface_recieved_motor_data.emit()


func _parse_bytes_as_vector3(bytes: PackedByteArray) -> Vector3:
	var arr: PackedFloat32Array = bytes.to_float32_array()
	return Vector3(arr[0], arr[1], arr[2])

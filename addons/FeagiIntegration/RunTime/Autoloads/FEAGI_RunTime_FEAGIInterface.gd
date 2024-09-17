extends Node
class_name FEAGI_RunTime_FEAGIInterface

const HTTP_WORKER_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/RunTime/Networking/FEAGIHTTP.tscn")

signal socket_closed()
signal socket_state_changed(new_state: WebSocketPeer.State)
signal socket_recieved_motor_data(motor_data: Dictionary) # dictionary structure is {device_type str : {device_ID int : data packedbytearray}}}

var connection_active: bool = false

var _cached_FEAGI_sensors: Array[FEAGI_IOHandler_Sensory_Base]

var _socket: WebSocketPeer
var _socket_state: WebSocketPeer.State = WebSocketPeer.State.STATE_CLOSED
var _FEAGI_sending_dict_structure: Dictionary ## Cached dict
var _FEAGI_receiving_dict_structure: Dictionary ## Cached dict


func _process(delta: float) -> void:
	if not _socket:
		return
	_socket.poll()
	if _socket.get_ready_state() != _socket_state:
		_socket_state = _socket.get_ready_state()
		socket_state_changed.emit(_socket_state)
	match(_socket_state):
		WebSocketPeer.State.STATE_OPEN:
			while _socket.get_available_packet_count():
				_on_motor_receive(_socket.get_packet())
		WebSocketPeer.State.STATE_CLOSED:
			push_error("FEAGI: WS Socket to connector closed!")
			socket_closed.emit()
			_socket = null
			set_process(false)

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

## ASYNC Initialize Websocket
func setup_websocket(full_connector_WS_address: StringName) -> bool:
	set_process(true)
	_socket = WebSocketPeer.new()
	_socket_state = WebSocketPeer.State.STATE_CLOSED
	_socket.connect_to_url(full_connector_WS_address)
	_socket_state = WebSocketPeer.State.STATE_CONNECTING
	await socket_state_changed
	var successful: bool = _socket_state == WebSocketPeer.State.STATE_OPEN
	if not successful:
		set_process(false)
		_socket = null
		connection_active = false
		return false
	connection_active = true
	return true

## Send the dicts used to define the device listings
func set_cached_device_dicts(sensors: Dictionary, motors: Dictionary) -> void:
	_cached_FEAGI_sensors.assign(sensors.values())
	
	# setup dictionary layout of reciving and sending dicts so we dont constantly have to reformat them
	for sensor: FEAGI_IOHandler_Sensory_Base in sensors.values():
		if sensor.get_device_type() not in _FEAGI_sending_dict_structure:
			_FEAGI_sending_dict_structure[sensor.get_device_type()] = {}
		if sensor.device_ID not in _FEAGI_sending_dict_structure[sensor.get_device_type()]:
			_FEAGI_sending_dict_structure[sensor.get_device_type()][sensor.device_ID] = PackedByteArray()
	
	for motor: FEAGI_IOHandler_Motor_Base in motors.values():
		if motor.get_device_type() not in _FEAGI_receiving_dict_structure:
			_FEAGI_receiving_dict_structure[ motor.get_device_type()] = {}
		if motor.device_ID not in _FEAGI_receiving_dict_structure[motor.get_device_type()]:
			_FEAGI_receiving_dict_structure[motor.get_device_type()][motor.device_ID] = PackedByteArray()
		
	

## ASYNC initialize connector with the configurator json
func send_final_configurator_JSON(configurator_JSON: StringName) -> void:
	if not _socket:
		return
	_socket.send((configurator_JSON.to_ascii_buffer()).compress(FileAccess.COMPRESSION_DEFLATE))
	await get_tree().create_timer(0.2).timeout # await connector to process

## Called when we need to send sensory data to FEAGI
func on_sensor_tick() -> void:
	if not _socket:
		push_error("FEAGI: Cannot send data to a closed socket!")
		return
	#for sensor in _cached_FEAGI_sensors: NOTE: This comment of code directly translates bytes to string. THis was an attempt to translate what we were doing to the current standard but didnt work. Still keeping this here as a template. for now we will use a worse performing implementation that works with the current JSON nonsense we have
	#	_FEAGI_sending_dict_structure[sensor.get_device_type()][sensor.device_ID] = sensor.get_data_as_byte_array() # Retrieves cached sensor byte data. Make sure this was recently updated!
	for sensor in _cached_FEAGI_sensors:
		if sensor.get_device_type() == "camera":
			_FEAGI_sending_dict_structure[sensor.get_device_type()][sensor.device_ID] = sensor.get_data_as_byte_array()
			continue
		else: # WARNING: temporarily using a temp function to get around json issue
			if sensor.get_device_type() == "proximity":
				_FEAGI_sending_dict_structure[sensor.get_device_type()][sensor.device_ID] =  sensor.get_data_as_byte_array().decode_float(0)
				continue
			if sensor.get_device_type() == "gyro" or sensor.get_device_type() == "accelerometer":
				var temp: Vector3 = FEAGI_IOHandler_Sensory_Accelerometer.byte_array_to_vector3(sensor.get_data_as_byte_array())
				_FEAGI_sending_dict_structure[sensor.get_device_type()][sensor.device_ID] = [temp.x, temp.y, temp.z]
		# RIP frames
	
	print(str(_FEAGI_sending_dict_structure))
	_socket.send(str(_FEAGI_sending_dict_structure).to_ascii_buffer().compress(FileAccess.COMPRESSION_DEFLATE))

func _on_motor_receive(raw_data: PackedByteArray) -> void:
	print(raw_data.get_string_from_utf8())
	
	

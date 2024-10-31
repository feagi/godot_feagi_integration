extends RefCounted
class_name FEAGI_RunTime_DebugInterface
## A class that allows for the runtime of FEAGI to talk back and forth with the debugger running in the editor

#TODO WARNING since desyncs are possible to the remote debugger session, we could get old data ticks after a device has been removed, causing weird issues. Maybe add a short period following device count changes where tick data isnt sent?

# WARNING see bottom warning about intertacting with these arrays
var _sensors: Array[FEAGI_IOConnector_Sensor_Base] = []
var _cached_sensor_sending_data: Array[PackedByteArray] = []
var _motors: Array[FEAGI_IOConnector_Motor_Base] = []
var _cached_motor_sending_data: Array[PackedByteArray] = []

## Alerts the remote debugger instance that a new Registration Agent sensor has been added, and to expect its data coming in data updates
func alert_debugger_about_sensor_creation(FEAGI_sensor: FEAGI_IOConnector_Sensor_Base) -> void:
	EngineDebugger.send_message("FEAGI:add_sensor", FEAGI_sensor.get_debug_interface_device_creation_array())
	_add_sensor(FEAGI_sensor)

func alert_debugger_about_motor_creation(FEAGI_motor: FEAGI_IOConnector_Motor_Base) -> void:
	EngineDebugger.send_message("FEAGI:add_motor", FEAGI_motor.get_debug_interface_device_creation_array())
	_add_motor(FEAGI_motor)

## Builds an array of all sensory data in ordered PackedByteArrays. NOTE: Retrieves data from sensor cache, so ensure the sensors just had their sensor values updated!
func alert_debugger_about_sensor_update() -> void:
	for i in len(_sensors):
		_cached_sensor_sending_data[i] = _sensors[i].get_cached_data_as_byte_array()
	EngineDebugger.send_message("FEAGI:sensor_data", _cached_sensor_sending_data)

## Builds an array of all motor data in ordered PackedByteArrays. NOTE: Retrieves data from motor cache, so ensure the motors just had their motor values updated!
func alert_debugger_about_motor_update() -> void:
	for i in len(_motors):
		_cached_motor_sending_data[i] = _motors[i].get_cached_data_as_byte_array()
	EngineDebugger.send_message("FEAGI:motor_data", _cached_motor_sending_data)


# WARNING: Only interact with the arrays using these functions to avoid desyncs with the remote debugger instance

func _add_sensor(FEAGI_sensor: FEAGI_IOConnector_Sensor_Base) -> void:
	_sensors.append(FEAGI_sensor)
	_cached_sensor_sending_data.append(FEAGI_sensor.get_cached_data_as_byte_array())

func _remove_sensor(FEAGI_sensor: FEAGI_IOConnector_Base) -> void:
	var index: int = _sensors.find(FEAGI_sensor)
	if index == -1:
		push_error("FEAGI: Unable to find device of name %s in the debug cache to remove!" % FEAGI_sensor.device_friendly_name)
		return
	_sensors.remove_at(index)
	_cached_sensor_sending_data.remove_at(index)

func _add_motor(FEAGI_motor: FEAGI_IOConnector_Motor_Base) -> void:
	_motors.append(FEAGI_motor)
	_cached_motor_sending_data.append(FEAGI_motor.get_cached_data_as_byte_array())

func _remove_motor(FEAGI_motor: FEAGI_IOConnector_Motor_Base) -> void:
	var index: int = _motors.find(FEAGI_motor)
	if index == -1:
		push_error("FEAGI: Unable to find device of name %s in the debug cache to remove!" % FEAGI_motor.device_friendly_name)
		return
	_motors.remove_at(index)
	_cached_motor_sending_data.remove_at(index)

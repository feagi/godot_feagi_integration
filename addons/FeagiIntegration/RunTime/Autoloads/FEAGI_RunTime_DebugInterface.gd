extends RefCounted
class_name FEAGI_RunTime_DebugInterface
## A class that allows for the runtime of FEAGI to talk back and forth with the debugger running in the editor

#TODO WARNING since desyncs are possible to the remote debugger session, we could get odl data ticks after a device has been removed, causing weird issues. Maybe add a short period following device count changes when tick data isnt sent?

# WARNING see bottom warning about intertacting with these arrays
var _sensors: Array[FEAGI_IOHandler_Base] = []
var _cached_sensor_sending_data: Array = []

## Alerts the remote debugger instance that a new godot device sensor has been added, and to expect its data coming in data updates
func alert_debugger_about_sensor_creation(FEAGI_sensor: FEAGI_IOHandler_Sensory_Base) -> void:
	EngineDebugger.send_message("FEAGI:add_sensor", FEAGI_sensor.get_debug_interface_device_creation_array())
	_add_sensor(FEAGI_sensor)

func alert_debugger_about_sensor_removal():
	#TODO
	pass

#TODO motor

func alert_debugger_about_sensor_update() -> void:
	for i in len(_sensors):
		_cached_sensor_sending_data[i] = _sensors[i].get_data_as_byte_array()
	EngineDebugger.send_message("FEAGI:sensor_data", _cached_sensor_sending_data)


# WARNING: Only interact with the arrays using these functions to avoid desyncs with the remote debugger instance

func _add_sensor(FEAGI_sensor: FEAGI_IOHandler_Sensory_Base) -> void:
	_sensors.append(FEAGI_sensor)
	_cached_sensor_sending_data.append(FEAGI_sensor.get_data_as_byte_array())

func _remove_sensor(FEAGI_sensor: FEAGI_IOHandler_Base) -> void:
	var index: int = _sensors.find(FEAGI_sensor)
	if index == -1:
		push_error("FEAGI: Unable to find device of name %s in the debug cache to remove!" % FEAGI_sensor.device_name)
		return
	_sensors.remove_at(index)
	_cached_sensor_sending_data.remove_at(index)

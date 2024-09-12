extends RefCounted
class_name FEAGI_RunTime_DebugInterface
## A class that allows for the runtime of FEAGI to talk back and forth with the debugger running in the editor

#TODO WARNING since desyncs are possible to the remote debugger session, we could get odl data ticks after a device has been removed, causing weird issues. Maybe add a short period following device count changes when tick data isnt sent?

# WARNING see bottom warning about intertacting with these arrays
var _devices: Array[FEAGI_IOHandler_Base] = []
var _cached_sending_data: Array = []

## Alerts the remote debugger instance that a new godot device has been added, and to expect its data coming in data updates
func alert_debugger_about_device_creation(FEAGI_device: FEAGI_IOHandler_Base) -> void:
	EngineDebugger.send_message("FEAGI:add_device", FEAGI_device.get_debug_interface_device_creation_array())
	_add_device(FEAGI_device)
	_devices.append(FEAGI_device)
	_cached_sending_data.append(FEAGI_device.get_data_as_byte_array())

func alert_debugger_about_device_removal():
	#TODO
	pass

func alert_debugger_about_data_update() -> void:
	for i in len(_devices):
		_cached_sending_data[i] = _devices[i].get_data_as_byte_array()
	EngineDebugger.send_message("FEAGI:data", _cached_sending_data)


# WARNING: Only interact with the arrays using these functions to avoid desyncs with the remote debugger instance

func _add_device(FEAGI_device: FEAGI_IOHandler_Base) -> void:
	_devices.append(FEAGI_device)
	_cached_sending_data.append(FEAGI_device.get_data_as_byte_array())

func _remove_device(FEAGI_device: FEAGI_IOHandler_Base) -> void:
	var index: int = _devices.find(FEAGI_device)
	if index == -1:
		push_error("FEAGI: Unable to find device of name %s in the debug cache to remove!" % FEAGI_device.device_name)
		return
	_devices.remove_at(index)
	_cached_sending_data.remove_at(index)

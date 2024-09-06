extends RefCounted
class_name FEAGIRunTimeDebugInterface
## A class that allows for the runtime of FEAGI to talk backa dn forth with the debugger running in the editor

var _devices: Array[FEAGI_IOHandler_Base] = []
var _cached_sending_data: Array = []

func alert_debugger_about_device_creation(is_motor: bool, device: FEAGI_IOHandler_Base) -> void:
	EngineDebugger.send_message("FEAGI:add_device", [is_motor, device.get_device_type(), device.device_name])
	_devices.append(device)
	_cached_sending_data.append(device.get_debug_data())

func alert_debugger_about_device_removal():
	#TODO
	pass


func alert_debugger_about_data_update() -> void:
	for i in len(_devices):
		#_cached_sending_data[i] = _devices[i].get_debug_data()
		_cached_sending_data[i] = _devices[i].get_debug_data()
	EngineDebugger.send_message("FEAGI:data", _cached_sending_data)
	

func message_FEAGI_device_rename(is_motor: bool, device_type: String, old_device_name: String, new_device_name: String):
	#todo?
	pass

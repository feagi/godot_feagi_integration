extends RefCounted
class_name FEAGIRunTimeDebugInterface
## A class that allows for the runtime of FEAGI to talk backa dn forth with the debugger running in the editor

func message_FEAGI_device_creation(is_motor: bool, device_type: String, device_name: String) -> void:
	EngineDebugger.send_message("FEAGI:add_device", [is_motor, device_type, device_name])

func message_FEAGI_device_removal():
	#todo
	pass

func message_FEAGI_data():
	#todo
	pass

func message_FEAGI_device_rename(is_motor: bool, device_type: String, old_device_name: String, new_device_name: String):
	#todo?
	pass

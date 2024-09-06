@tool
extends ScrollContainer
class_name FEAGI_UI_Panel_DeviceList
## Handles spawning the devices

var _device_holder: VBoxContainer

const DEVICE_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/Editor/Panel/Components/Devices/Device_Specific_UIs/FEAGI_UI_Panel_Device.tscn")

const SPECIFIC_DEVICE_UI_PATHS_SENSORY: Dictionary = {
	"camera": "res://addons/FeagiIntegration/Editor/Panel/Components/Devices/Device_Specific_UIs/Sensory/FEAGI_UI_Panel_SpecificSensoryDevice_Camera.tscn"
}

const SPECIFIC_DEVICE_UI_PATHS_MOTOR: Dictionary = {
}

var _is_sensory: bool
var _device_count: Dictionary = {} # key'd by device type name, values are the int count of each currently loaded. Used to calculate device indexes
var _device_names: Dictionary = {} # key'd by device type name, values are an array of strings of all names of that device type. Used to prevent duplicate names

func setup(is_sensory: bool) -> void:
	_device_holder = $VBoxContainer
	_is_sensory = is_sensory
	var possible_device_type_names: PackedStringArray
	if is_sensory:
		possible_device_type_names = FEAGI_PLUGIN.GODOT_SUPPORTED_SENSORS
	else:
		possible_device_type_names = FEAGI_PLUGIN.GODOT_SUPPORTED_MOTORS
	for possible_device_type_name in possible_device_type_names:
		_device_count[possible_device_type_name] = 0
		_device_names[possible_device_type_name] = PackedStringArray()
	



func spawn_device_new(device_type: StringName, configurator_template: Dictionary) -> void:
	var device_specific_UI: FEAGI_UI_Panel_SpecificDeviceUI_Base
	if _is_sensory:
		if device_type not in SPECIFIC_DEVICE_UI_PATHS_SENSORY:
			push_error("FEAGI: Cannot spawn unknown sensory device type %s!" % device_type)
			return
		device_specific_UI = SPECIFIC_DEVICE_UI_PATHS_SENSORY[device_type]
	else:
		if device_type not in SPECIFIC_DEVICE_UI_PATHS_MOTOR:
			push_error("FEAGI: Cannot spawn unknown motor device type %s!" % device_type)
			return
		device_specific_UI = SPECIFIC_DEVICE_UI_PATHS_MOTOR[device_type]
	
	var device: FEAGI_UI_Panel_Device = DEVICE_PREFAB.instantiate()
	var device_index: int = _device_count[device_type]
	var device_name_index: int = device_index + 1
	_device_count[device_type] += 1
	var device_name: StringName = device_type + " " + str(device_name_index)
	while device in _device_names[device_type]:
		device_name_index += 1
		device_name = device_type + " " + str(device_name_index)
	
	_device_holder.add_child(device)
	device.confirm_name_change.connect(_confirm_device_name_change_request)
	device.setup(device_type, device_index, device_name, false, device_specific_UI, configurator_template)



func _device_removed(device_ref: FEAGI_UI_Panel_Device) -> void:
	_device_count[device_ref.device_type] -= 1
	var device_name_index: int = (_device_names[device_ref.device_friendly_name] as PackedStringArray).find(device_ref.device_friendly_name)
	if device_name_index > 0:
		(_device_names[device_ref.device_friendly_name] as PackedStringArray).remove_at(device_name_index)



func _confirm_device_name_change_request(requesting_new_name: StringName, device_ref: FEAGI_UI_Panel_Device) -> void:
	if requesting_new_name in _device_names[device_ref.device_type]:
		device_ref.set_device_name(device_ref.device_friendly_name) # Reject, reset textbox
	else:
		device_ref.set_device_name(requesting_new_name) # Accept
		
	
	
	
	

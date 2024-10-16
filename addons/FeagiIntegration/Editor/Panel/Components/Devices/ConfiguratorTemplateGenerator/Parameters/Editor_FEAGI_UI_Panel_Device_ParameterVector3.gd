@tool
extends Editor_FEAGI_UI_Panel_Device_ParameterBase
class_name Editor_FEAGI_UI_Panel_Device_ParameterVector3

var _x: SpinBox
var _y: SpinBox
var _z: SpinBox


func setup(property_name: StringName, description: StringName) -> void:
	_x = $x
	_y = $y
	_z = $z
	base_setup(property_name, description)

func set_value(value: Variant) -> void:
	# Assuming the input is a array inmput of 3 floats
	if value is not Array:
		push_error("Input for parameter of type Vector3 is not an array!")
		return
	if len(value as Array) != 3:
		push_error("Input array for parameter of type Vector3 is not 3 numbers long!")
		return
	_x.value = (value as Array)[0]
	_y.value = (value as Array)[1]
	_z.value = (value as Array)[2]

func get_value() -> Variant:
	return [_x.value, _y.value, _z.value]

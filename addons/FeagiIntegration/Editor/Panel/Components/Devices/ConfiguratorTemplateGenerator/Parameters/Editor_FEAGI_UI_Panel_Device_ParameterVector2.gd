@tool
extends Editor_FEAGI_UI_Panel_Device_ParameterBase
class_name Editor_FEAGI_UI_Panel_Device_ParameterVector2


var _x: SpinBox
var _y: SpinBox


func setup(property_name: StringName, description: StringName) -> void:
	_x = $x
	_y = $y
	base_setup(property_name, description)

func set_value(value: Variant) -> void:
	# Assuming the input is a array inmput of 2 floats
	if value is not Array:
		push_error("Input for parameter of type Vector2 is not an array!")
		return
	if len(value as Array) != 2:
		push_error("Input array for parameter of type Vector2 is not 2 numbers long!")
		return
	
	_x.value = (value as Array)[0]
	_y.value = (value as Array)[1]

func get_value() -> Variant:
	return [_x.value, _y.value]

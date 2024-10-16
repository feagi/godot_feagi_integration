@tool
extends Editor_FEAGI_UI_Panel_Device_ParameterBase
class_name Editor_FEAGI_UI_Panel_Device_ParameterInt

var _int: SpinBox
	
func setup(property_name: StringName, description: StringName) -> void:
	_int = $Value
	base_setup(property_name, description)

func set_value(value: Variant) -> void:
	_int.value = value

func get_value() -> Variant:
	return _int.value

func set_max(max_value: int) -> void:
	_int.max_value = max_value

func set_min(min_value: int) -> void:
	_int.min_value = min_value

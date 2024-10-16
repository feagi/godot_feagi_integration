@tool
extends Editor_FEAGI_UI_Panel_Device_ParameterBase
class_name Editor_FEAGI_UI_Panel_Device_ParameterFloat

var _float: SpinBox


func setup(property_name: StringName, description: StringName) -> void:
	_float = $Value
	base_setup(property_name, description)

func set_value(value: Variant) -> void:
	_float.value = value

func get_value() -> Variant:
	return _float.value

func set_max(max_value: float) -> void:
	_float.max_value = max_value

func set_min(min_value: float) -> void:
	_float.min_value = min_value

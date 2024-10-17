@tool
extends Editor_FEAGI_UI_Panel_Device_ParameterBase
class_name Editor_FEAGI_UI_Panel_Device_ParameterPercentage

var _percent: SpinBox
	
func setup(property_name: StringName, description: StringName) -> void:
	_percent = $Value
	base_setup(property_name, description)

func set_value(value: Variant) -> void:
	_percent.value = value

func get_value() -> Variant:
	return _percent.value

func set_max(max_value: float) -> void:
	_percent.max_value = max_value

func set_min(min_value: float) -> void:
	_percent.min_value = min_value

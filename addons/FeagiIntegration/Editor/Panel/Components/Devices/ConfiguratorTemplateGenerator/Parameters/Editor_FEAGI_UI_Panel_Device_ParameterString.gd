@tool
extends Editor_FEAGI_UI_Panel_Device_ParameterBase
class_name Editor_FEAGI_UI_Panel_Device_ParameterString

var _string: LineEdit

func setup(property_name: StringName, description: StringName) -> void:
	_string = $Value
	base_setup(property_name, description)

func set_value(value: Variant) -> void:
	_string.text = value

func get_value() -> Variant:
	return _string.text

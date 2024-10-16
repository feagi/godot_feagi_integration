@tool
extends Editor_FEAGI_UI_Panel_Device_ParameterBase
class_name Editor_FEAGI_UI_Panel_Device_ParameterBool

signal bool_changed(boolean: bool)
signal bool_changed_inversed(boolean: bool)

var _bool: CheckBox

func setup(property_name: StringName, description: StringName) -> void:
	_bool = $Value
	base_setup(property_name, description)
	_bool.toggled.connect(func(x: bool) : bool_changed.emit(x))
	_bool.toggled.connect(func(x: bool) : bool_changed_inversed.emit(!x))

func set_value(value: Variant) -> void:
	_bool.button_pressed = value

func get_value() -> Variant:
	return _bool.button_pressed

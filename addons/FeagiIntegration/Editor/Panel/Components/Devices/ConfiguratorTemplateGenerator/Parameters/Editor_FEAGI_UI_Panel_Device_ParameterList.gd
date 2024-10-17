@tool
extends Editor_FEAGI_UI_Panel_Device_ParameterBase
class_name Editor_FEAGI_UI_Panel_Device_ParameterList

var _internals: Array[Editor_FEAGI_UI_Panel_Device_ParameterBase] = []

func setup(property_name: StringName, description: StringName) -> void:
	base_setup(property_name, description)

func setup_internals(internals: Array[Editor_FEAGI_UI_Panel_Device_ParameterBase]) -> void:
	_internals = internals
	for interal in internals:
		add_child(interal)

func set_value(value: Variant) -> void:
	# This takes in an array
	for index in range(len(value)):
		_internals[index].set_value(value[index])

func get_value() -> Variant:
	var output: Array = []
	for internal in _internals:
		output.append(internal.get_value())
	return output

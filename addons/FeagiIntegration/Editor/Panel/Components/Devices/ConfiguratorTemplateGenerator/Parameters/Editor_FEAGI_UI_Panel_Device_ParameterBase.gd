@tool
extends HBoxContainer
class_name Editor_FEAGI_UI_Panel_Device_ParameterBase
## Semi-surperflous base class for setting name / value objects


var flag_for_toggle_by_parameter_of_name: StringName = ""
var flag_for_inverse_toggle_by_parameter_of_name: StringName = ""

func base_setup(label: StringName, description: StringName) -> void:
	var label_text: Label = $Label
	label_text.text = label
	label_text.tooltip_text = description
	name = label

func set_value(_value: Variant) -> void:
	pass

func get_value() -> Variant:
	return null

func get_value_as_dict() -> Dictionary:
	return {name: get_value()}

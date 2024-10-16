@tool
extends VBoxContainer
class_name Editor_FEAGI_Debug_Panel_ViewBase

var _title: Label
var _collapse_button: TextureButton
var _holder: Control ## Holds the data we may be showing or not
var _is_collapsed: bool = true

func initialize() -> void:
	_title = $Title/MarginContainer/VBoxContainer/HBoxContainer/Name
	_collapse_button = $Title/MarginContainer/VBoxContainer/HBoxContainer/Collapse
	_holder = $Title/MarginContainer/VBoxContainer/holder
	

## Used to initialize the details of the device. Typically "_extra_setup_data" is unused in most cases
func setup_base(device_FEAGI_name: StringName, _extra_setup_data: Array) -> void:
	_title.text = device_FEAGI_name
	if len(_extra_setup_data) != 0:
		setup_extra_setup_data(_extra_setup_data)

## A few devices need extra context to setup (such as camera needing resolution), but devices dont need this
func setup_extra_setup_data(_extra_setup_data: Array) -> void:
	pass

func is_collapsed() -> bool:
	return _is_collapsed

func set_collapsed(collapse: bool) -> void:
	if collapse:
		_collapse_button.texture_normal = load("res://addons/FeagiIntegration/Editor/Resources/Icons/Triangle_Right_S.png")
		_collapse_button.texture_hover = load("res://addons/FeagiIntegration/Editor/Resources/Icons/Triangle_Right_H.png")
		_collapse_button.texture_pressed = load("res://addons/FeagiIntegration/Editor/Resources/Icons/Triangle_Right_C.png")
	else:
		_collapse_button.texture_normal = load("res://addons/FeagiIntegration/Editor/Resources/Icons/Triangle_Down_S.png")
		_collapse_button.texture_hover = load("res://addons/FeagiIntegration/Editor/Resources/Icons/Triangle_Down_H.png")
		_collapse_button.texture_pressed = load("res://addons/FeagiIntegration/Editor/Resources/Icons/Triangle_Down_C.png")
	_is_collapsed = collapse
	_holder.visible = !collapse

# Overridden in child classes, the function that recieves a PackedByteArray to update the visualization of the device
func update_visualization(data: PackedByteArray) -> void:
	return

func _toggle_collapse() -> void:
	set_collapsed(!_is_collapsed)

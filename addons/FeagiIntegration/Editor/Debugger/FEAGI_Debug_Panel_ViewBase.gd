@tool
extends VBoxContainer
class_name FEAGI_Debug_Panel_ViewBase

var _title: Label
var _collapse_button: TextureButton
var _holder: Control ## Holds the data we may be showing or not
var _is_collapsed: bool = true

func initialize() -> void:
	_title = $Title/MarginContainer/VBoxContainer/HBoxContainer/Name
	_collapse_button = $Title/MarginContainer/VBoxContainer/HBoxContainer/Collapse
	_holder = $Title/MarginContainer/VBoxContainer/holder
	_collapse_button.pressed.connect(_toggle_collapse)

func setup_base(device_FEAGI_name: StringName) -> void:
	_title.text = device_FEAGI_name

func is_collapsed() -> bool:
	return _is_collapsed

func set_collapsed(collapse: bool) -> void:
	if collapse:
		_collapse_button.texture_normal = load("res://addons/FeagiIntegration/Window/Resources/Icons/Triangle_Right_S.png")
		_collapse_button.texture_hover = load("res://addons/FeagiIntegration/Window/Resources/Icons/Triangle_Right_H.png")
		_collapse_button.texture_pressed = load("res://addons/FeagiIntegration/Window/Resources/Icons/Triangle_Right_C.png")
	else:
		_collapse_button.texture_normal = load("res://addons/FeagiIntegration/Window/Resources/Icons/Triangle_Down_S.png")
		_collapse_button.texture_hover = load("res://addons/FeagiIntegration/Window/Resources/Icons/Triangle_Down_H.png")
		_collapse_button.texture_pressed = load("res://addons/FeagiIntegration/Window/Resources/Icons/Triangle_Down_C.png")
	_is_collapsed = collapse
	_holder.visible = !collapse

# Override this in child classes
func update_visualization(data: Variant) -> void:
	return

func _toggle_collapse() -> void:
	set_collapsed(!_is_collapsed)

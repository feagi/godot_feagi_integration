extends PanelContainer
class_name FEAGIRemoteIOMapping

var _type: LineEdit
var _name: LineEdit
var _device_ID: SpinBox


func _ready() -> void:
	_type = $VBoxContainer/Type/Type
	_name = $VBoxContainer/Name/Name
	_device_ID = $VBoxContainer/Mapping/Mapping

func setup(type_as_string: StringName, current_name: StringName, current_ID: int, name_change_signal: Signal, close_signal: Signal) -> void:
	_type.text = type_as_string
	_name_updated(current_name)
	name_change_signal.connect(_name_updated)
	_device_ID.value = current_ID
	close_signal.connect(queue_free)

func _name_updated(new_name: StringName) -> void:
	_name.text = new_name

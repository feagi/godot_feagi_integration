@tool
extends VBoxContainer
class_name FEAGISectionFEAGIIO

const IO_REMOTE_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/Window/Remote_IO/FEAGIRemoteIOMapping.tscn")

var _scroll_container: VBoxContainer

func _ready() -> void:
	_scroll_container = $ScrollContainer/VBoxContainer
	

func sensory_added(local_IO_object: BaseFEAGILocalIO) -> void:
	var io: FEAGIRemoteIOMapping = IO_REMOTE_PREFAB.instantiate()
	io.setup(local_IO_object.get_type_as_string() ,local_IO_object.get_current_name(), 0, local_IO_object.request_input_name_change, local_IO_object.tree_exited)

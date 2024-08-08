@tool
# Copyright 2016-2024 The FEAGI Authors. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 	http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
extends VBoxContainer
class_name BaseFEAGILocalIO
## Base class for all local (godot / robot / etc) side configurations for IO

signal request_input_name_change(input_type: FEAGIPluginInit.INPUT_TYPE, requesting_name: StringName)
signal request_output_name_change(output_type: FEAGIPluginInit.OUTPUT_TYPE, requesting_name: StringName)
signal name_change_accepted(new_name: StringName)

@export var IO_type_as_string: StringName
@export var IO_icon: Texture

var _is_input: bool
var _input_type: FEAGIPluginInit.INPUT_TYPE
var _output_type: FEAGIPluginInit.OUTPUT_TYPE
var _header: FEAGIIOHeader

func _ready() -> void:
	_header = $FEAGIIOHeader
	_header.changed_collapsed_state.connect(_respond_to_collapsed_state_change)
	_header.closed_pressed.connect(queue_free)
	_header.user_request_name_change.connect(_user_requesting_name_change)

func set_collapsed_state(is_collapsed: bool) -> void:
	_header.set_collapsed_state(is_collapsed) # NOTE: This emits a signal that fires '_respond_to_collapsed_state_change'

## Setup this object using the input type
func _setup_as_input(input_type: FEAGIPluginInit.INPUT_TYPE, initial_name: StringName) -> void:
	_is_input = true
	_header.setup(initial_name, FEAGIPluginInit.INPUT_TYPE.keys()[input_type], IO_icon)

## Setup this object using the output type
func _setup_as_output(output_type: FEAGIPluginInit.OUTPUT_TYPE, initial_name: StringName) -> void:
	_is_input = false
	_header.setup(initial_name, FEAGIPluginInit.OUTPUT_TYPE.keys()[output_type], IO_icon)

func _user_requesting_name_change(new_name: StringName) -> void:
	if _is_input:
		request_input_name_change.emit(_input_type, new_name)
	else:
		request_output_name_change.emit(_output_type, new_name)

func confirmed_name_change(new_name: StringName) -> void:
	_header.new_name_confirmed(new_name)
	name_change_accepted.emit(new_name)

#NOTE This may need to be overridden on more complex local IOs
func _respond_to_collapsed_state_change(is_collapsed: bool) -> void:
	for i in get_child_count():
		if i == 0:
			continue #NOTE: THe FEAGIIOHeader has its own logic
		get_child(i).visible = !is_collapsed

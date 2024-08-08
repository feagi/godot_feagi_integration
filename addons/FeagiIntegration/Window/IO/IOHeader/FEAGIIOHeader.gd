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
class_name FEAGIIOHeader

signal changed_collapsed_state(is_collapsed: bool)
signal closed_pressed()
signal user_request_input_ID_change(input_type: FEAGIPluginInit.INPUT_TYPE, requesting_ID: int)
signal user_request_input_name_change(input_type: FEAGIPluginInit.INPUT_TYPE, requesting_name: StringName)
signal user_request_output_ID_change(output_type: FEAGIPluginInit.OUTPUT_TYPE, requesting_ID: int)
signal user_request_output_name_change(output_type: FEAGIPluginInit.OUTPUT_TYPE, requesting_name: StringName)

@export var IO_type: StringName
@export var IO_icon: Texture

var _is_collapsed: bool
var _input_type: FEAGIPluginInit.INPUT_TYPE
var _output_type: FEAGIPluginInit.OUTPUT_TYPE

var _icon: TextureRect
var _header_name: Label
var _expand: TextureButton
var _close: TextureButton
var _type: LineEdit
var _name: LineEdit
var _ID: SpinBox
var _type_section: HBoxContainer
var _name_section: HBoxContainer
var _ID_section: HBoxContainer

func _ready() -> void:
	_icon = $Bar/Icon
	_header_name = $Bar/NameID
	_expand = $Bar/Expand
	_close = $Bar/Close
	_type = $Type/Type
	_name = $Name/Name
	_ID = $ID/ID
	_type_section = $Type
	_name_section = $Name
	_ID_section = $ID

func setup_input(input_type: FEAGIPluginInit.INPUT_TYPE, inital_ID: int, initial_name: StringName) -> void:
	_input_type = input_type
	_ID.value = inital_ID
	_name.text = initial_name
	_update_header_title(initial_name, inital_ID)
	#TODO set icon

## Use to toggle if this section is expanded or not
func toggle_collapsed_state() -> void:
	set_collapsed_state(!_is_collapsed)

## Use to set if this section is expanded or not
func set_collapsed_state(is_collapsed: bool) -> void:
	_type_section.visible = !is_collapsed
	_name_section.visible = !is_collapsed
	_ID_section.visible = !is_collapsed
	changed_collapsed_state.emit(is_collapsed)
	_is_collapsed = is_collapsed
	#TODO set icons

func _update_header_title(IO_name: StringName, IO_ID: int) -> void:
	_header_name.text = "%s [%d]" % [IO_name, IO_ID]

func _user_pressed_close_button() -> void:
	closed_pressed.emit()

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
signal user_request_name_change(requesting_name: StringName)


@export var IO_icon: Texture

var _is_collapsed: bool

var _icon: TextureRect
var _header_name: Label
var _expand: TextureButton
var _close: TextureButton
var _type: LineEdit
var _name: LineEdit
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
	_type_section = $Type
	_name_section = $Name
	_ID_section = $ID

func setup(initial_name: StringName, IO_type_as_string: StringName) -> void:
	_type.text = IO_type_as_string
	_name.text = initial_name
	_header_name.text = initial_name
	_icon.texture = IO_icon

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

func new_name_confirmed(new_name: StringName) -> void:
	_name.text = new_name
	_header_name.text = new_name

func _user_pressed_close_button() -> void:
	closed_pressed.emit()

func _user_request_name_change(new_name: StringName) -> void:
	user_request_name_change.emit(new_name)

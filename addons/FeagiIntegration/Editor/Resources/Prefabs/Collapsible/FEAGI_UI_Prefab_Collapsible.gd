"""
Copyright 2016-2024 The FEAGI Authors. All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
	http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================
"""
@tool
extends VBoxContainer
class_name FEAGI_UI_Prefab_Collapsible

@export var show_on_load: bool = false
@export var show_text: StringName = "Show"
@export var hide_text: StringName = "Hide"

var _show: Button
var _hide: Button
var _container: PanelContainer

func _ready():
	_show = $Show
	_hide = $Hide
	_container = $PanelContainer
	_show.text = show_text
	_hide.text = hide_text
	toggle_visibility(show_on_load)

## Show / Hide the internals of this control
func toggle_visibility(show_internals: bool) -> void:
	_show.visible = !show_internals
	_hide.visible = show_internals
	_container.visible = show_internals

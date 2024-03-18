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
class_name FEAGIWindowCollapsible

@export var show_on_load: bool = false

var _show: Button
var _hide: Button

func _ready():
	_show = $Show
	_hide = $Hide
	toggle_visibility(show_on_load)

## Show / Hide the internals of this control
func toggle_visibility(show_internals: bool) -> void:
	for child: Control in get_children():
		child.visible = show_internals
	_show.visible = !show_internals
	_hide.visible = show_internals

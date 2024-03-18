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
extends HBoxContainer
class_name FromFeagiLine

## Called by the creator after instantiation
func setup(UIAction: StringName) -> void:
	$UI_Action.text = UIAction

## Export the values here as a Array to be used to write the FEAGI configuration json -> [UI_map, key, val]
func export() -> Array[String]:
	var key: String = $FEAGI_Key.text
	var val: String = $FEAGI_Val.text
	var action: String = $UI_Action.text
	return [action, key, val]

func inport_settings(arr: Array) -> void:
	$FEAGI_Key.text = arr[1]
	$FEAGI_Val.text = arr[2]
	$UI_Action.text = arr[0]

## User pressed delete button
func _user_deleted() -> void:
	queue_free()

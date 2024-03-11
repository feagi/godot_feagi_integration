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
extends OptionButton
class_name FEAGIUIOptions

## Gets the latest possible action mappings of the project
func refresh_UI_mappings() -> void:
	clear()
	var actions: Array[StringName] = InputMap.get_actions()
	for action: StringName in actions:
		add_item(action)
	print("FEAGI: Refreshed available UI input mappings!")

func get_selected_mapping() -> StringName:
	var selection: int = get_selected_id()
	if selection <= -1:
		return &""
	return get_item_text(selection)

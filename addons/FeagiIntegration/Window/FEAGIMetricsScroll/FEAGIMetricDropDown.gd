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
class_name FEAGIMetricDropDown

@export var _metric_scroll: FEAGIMetricScroll

# Called when the node enters the scene tree for the first time.
func _ready():
	var emtpy_arr: Array[StringName] = [] # cause implicit array types are so hard gdscript...
	pressed.connect(update_list_availability)
	clear()
	for metric: StringName in FEAGIInterface.METRIC_MAPPINGS.keys():
		add_item(metric)

## Refreshes the list item availability, hides items that are already being used
func update_list_availability() -> void:
	var i: int = 0
	var already_enabled_metrics: Array[StringName] = _metric_scroll.export_settings()
	for metric: StringName in FEAGIInterface.METRIC_MAPPINGS.keys():
		set_item_disabled(i, metric in already_enabled_metrics)
		i = i + 1

func get_selected_metric() -> StringName:
	var selection: int = get_selected_id()
	if selection <= -1:
		return &""
	return get_item_text(selection)

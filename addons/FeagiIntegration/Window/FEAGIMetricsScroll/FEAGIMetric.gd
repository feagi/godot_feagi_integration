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
class_name FEAGIMetric

func setup(key: StringName) -> void:
	$ExpectedKey.text = key
	var expected_type: FEAGIInterface.EXPECTED_TYPE = FEAGIInterface.METRIC_MAPPINGS[key][1]
	$ExpectedType.text = FEAGIInterface.EXPECTED_TYPE.keys()[expected_type]
	tooltip_text = FEAGIInterface.METRIC_MAPPINGS[key][0]
	if expected_type == FEAGIInterface.EXPECTED_TYPE.PERCENTAGE:
		$ExpectedType.tooltip_text = "Just a float but limited to the range of 0.0 > 100.0"

func export() -> StringName:
		return $ExpectedKey.text

func _user_deleted() -> void:
	queue_free()

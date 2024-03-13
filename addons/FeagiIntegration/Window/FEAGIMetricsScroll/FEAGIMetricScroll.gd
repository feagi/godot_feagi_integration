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
extends ScrollContainer
class_name FEAGIMetricScroll


const FEAGI_METRIC_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/Window/FEAGIMetricsScroll/FeagiMetric.tscn")

var _container: VBoxContainer

func _ready() -> void:
	_container = $VBoxContainer

## Adds a new metric
func add_metric(metric: StringName) -> void:
	if metric == &"":
		push_warning("FEAGIPlugin: Please select a valid metric")
		return
	var new_metric: FEAGIMetric = FEAGI_METRIC_PREFAB.instantiate()
	_container.add_child(new_metric)
	new_metric.setup(metric)

## Assembles all the set metrics as a single dictionary out -> str metric key : str expected type
func export_settings() -> Array[StringName]:
	var output: Array[StringName]
	for child: Control in _container.get_children():
		if child is FEAGIMetric:
			output.append((child as FEAGIMetric).export())
	return output

## Mass spawns metrics
func import_settings(metrics: Array[StringName]) -> void:
	_delete_children()
	for metric: StringName in metrics:
			add_metric(metric)

func _delete_children() -> void:
	for child: Control in _container.get_children():
		child.queue_free()

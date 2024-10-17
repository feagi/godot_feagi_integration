extends Node
class_name FEAGI_RunTime_TickEngine
## Handles the firing of ticks, or refresh events in we grab all data. A FEAGI "frame" if you will

# NOTE: This abstraction exists because we may be moving away from timers at some point to something else

signal tick()

var _timer: Timer

func _enter_tree() -> void:
	name = "FEAGI Sensor TickEngine"

func setup(initial_frame_time: float) -> void:
	_timer = Timer.new()
	add_child(_timer)
	_timer.one_shot = false
	_set_refresh_rate(initial_frame_time)
	_timer.timeout.connect(_on_timer)
	_timer.start(initial_frame_time)

func set_paused(is_paused: bool) -> void:
	_timer.paused = is_paused

func _set_refresh_rate(frame_time: float) -> void:
	_timer.wait_time = frame_time

func _on_timer() -> void:
	tick.emit()

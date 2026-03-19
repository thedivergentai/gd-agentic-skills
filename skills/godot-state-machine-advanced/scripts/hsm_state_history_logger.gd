class_name HSMStateHistoryLogger
extends Node

## Expert Debug tool for State Machine History.
## Tracks a ring buffer of recent transitions for troubleshooting.

var history: Array[String] = []
@export var max_history: int = 20

func log_transition(from: String, to: String) -> void:
	var entry := "[%s] %s -> %s" % [Time.get_time_string_from_system(), from, to]
	history.push_back(entry)
	if history.size() > max_history:
		history.pop_front()

## Tip: Expose 'history' to the in-game debug console.

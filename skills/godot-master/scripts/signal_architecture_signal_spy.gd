# godot-master/scripts/signal_architecture_signal_spy.gd
extends Node

## Signal Spy Expert Pattern
## Runtime signal observer for debugging and testing.

class_name SignalSpy

var _observed_signals: Dictionary = {}

func observe(target: Object, signal_name: String) -> void:
	if not target.has_signal(signal_name):
		push_error("Signal '%s' not found on %s" % [signal_name, target])
		return
		
	var key := "%s::%s" % [target.get_instance_id(), signal_name]
	if key in _observed_signals:
		return  # Already observing
		
	_observed_signals[key] = {
		"target": target,
		"signal_name": signal_name,
		"emit_count": 0,
		"last_args": [],
		"history": []
	}
	
	target.get(signal_name).connect(
		func(args = []): _on_signal_emitted(key, args),
		CONNECT_REFERENCE_COUNTED
	)
	
	print("[Spy] Now observing: %s.%s" % [target.name if target is Node else target, signal_name])

func _on_signal_emitted(key: String, args) -> void:
	var data: Dictionary = _observed_signals[key]
	data["emit_count"] += 1
	data["last_args"] = args if args is Array else [args]
	data["history"].append({
		"time": Time.get_ticks_msec(),
		"args": data["last_args"]
	})
	
	print("[Spy] Signal emitted: %s.%s (count: %d, args: %s)" % [
		data["target"].name if data["target"] is Node else data["target"],
		data["signal_name"],
		data["emit_count"],
		str(data["last_args"])
	])

func get_emit_count(target: Object, signal_name: String) -> int:
	var key := "%s::%s" % [target.get_instance_id(), signal_name]
	return _observed_signals.get(key, {}).get("emit_count", 0)

func get_last_args(target: Object, signal_name: String) -> Array:
	var key := "%s::%s" % [target.get_instance_id(), signal_name]
	return _observed_signals.get(key, {}).get("last_args", [])

func was_emitted(target: Object, signal_name: String) -> bool:
	return get_emit_count(target, signal_name) > 0

func reset(target: Object, signal_name: String) -> void:
	var key := "%s::%s" % [target.get_instance_id(), signal_name]
	if key in _observed_signals:
		_observed_signals[key]["emit_count"] = 0
		_observed_signals[key]["last_args"] = []
		_observed_signals[key]["history"] = []

func print_report() -> void:
	print("\n=== Signal Spy Report ===")
	for key in _observed_signals:
		var data: Dictionary = _observed_signals[key]
		print("%s.%s: %d emissions" % [
			data["target"].name if data["target"] is Node else "?",
			data["signal_name"],
			data["emit_count"]
		])

## EXPERT NOTE:
## Use this for testing signals without mocking frameworks.
## Example:
##   var spy = SignalSpy.new()
##   spy.observe(player, "died")
##   player.health = 0
##   assert(spy.was_emitted(player, "died"))

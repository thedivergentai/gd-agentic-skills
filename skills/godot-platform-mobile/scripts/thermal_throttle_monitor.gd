class_name ThermalThrottleMonitor
extends Node

## Expert thermal and battery manager for Mobile.
## Throttles logic/rendering when app is backgrounded or device is hot.

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED:
			# Drop FPS to minimal to save battery and reduce heat
			Engine.max_fps = 1
			AudioServer.set_bus_mute(0, true)
		NOTIFICATION_APPLICATION_RESUMED:
			# Restore performance
			Engine.max_fps = 60
			AudioServer.set_bus_mute(0, false)

func apply_thermal_throttle(is_hot: bool) -> void:
	# Expert: Dynamic FPS scaling based on device temperature signal
	Engine.max_fps = 30 if is_hot else 60

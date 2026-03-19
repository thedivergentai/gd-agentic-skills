class_name ConsoleCertificationManager
extends Node

## Expert handler for TRC/TCR certification compliance.
## Automatically manages focus transitions and controller disconnections.

signal focus_lost
signal focus_gained
signal controller_disconnected(device_id: int)

func _ready() -> void:
	# TCR: Monitor joypad connectivity changes during runtime
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	process_mode = Node.PROCESS_MODE_ALWAYS

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			# TRC: System menu opened (Overlay). Must pause immediately.
			_enforce_system_pause()
			focus_lost.emit()
		NOTIFICATION_APPLICATION_FOCUS_IN:
			focus_gained.emit()

func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if not connected:
		# TRC: Controller disconnect must trigger a pause/overlay
		_enforce_system_pause()
		controller_disconnected.emit(device)

func _enforce_system_pause() -> void:
	if not get_tree().paused:
		get_tree().paused = true
		print("Console: Forced system pause due to focus loss or disconnect.")

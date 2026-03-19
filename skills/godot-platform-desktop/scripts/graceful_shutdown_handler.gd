class_name GracefulShutdownHandler
extends Node

## Expert handler for OS-level close requests (Alt+F4 / Window 'X').
## Ensures all data is flushed and saved before the process terminates.

func _ready() -> void:
	# Intercept the quit signal
	get_tree().set_auto_accept_quit(false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_on_close_requested()

func _on_close_requested() -> void:
	print("Desktop: Close requested. Flushing data...")
	# Trigger your SaveManager.save_all() synchronously here
	
	# Wait for I/O completion if necessary, then quit
	get_tree().quit()

## Warning: Skipping this often leads to corrupted .ini/.cfg files during force-quits.

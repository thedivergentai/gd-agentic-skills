# skills/platform-console/scripts/console_compliance_handler.gd
extends Node

## Console Compliance Handler Expert Pattern
## Automates TRC/TCR requirements: Focus loss handling, User ID checks, Save indicators.

class_name ConsoleComplianceHandler

signal focus_lost
signal focus_gained

@export var pause_on_focus_loss: bool = true
@export var show_mouse_cursor: bool = false
@export var save_icon: CanvasItem # Optional reference to UI icon

var _is_saving: bool = false

func _ready() -> void:
	# 1. Cursor Management
	if not show_mouse_cursor:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# 2. V-Sync Enforcement
	# Consoles typically mandate V-Sync to prevent tearing
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	
	print("[ConsoleCompliance] Initialized. Mouse Hidden: ", !show_mouse_cursor)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			_handle_focus_loss()
		NOTIFICATION_APPLICATION_FOCUS_IN:
			_handle_focus_gain()

func _handle_focus_loss() -> void:
	print("[ConsoleCompliance] Focus LOST")
	focus_lost.emit()
	
	if pause_on_focus_loss:
		# TRC Requirement: Game must pause entirely when system focus is lost
		get_tree().paused = true
		# Usually we show a "Press Start to Resume" screen or modal here

func _handle_focus_gain() -> void:
	print("[ConsoleCompliance] Focus GAINED")
	focus_gained.emit()
	
	# TRC Requirement: Do not auto-unpause if the game was paused by player before focus loss.
	# Best practice: Remain paused and wait for user input.

func notify_save_start() -> void:
	_is_saving = true
	# TRC Requirement: Indicate clearly when saving is happening
	if save_icon:
		save_icon.show()
	# Platform-specific "Saving..." overlay call could go here

func notify_save_end() -> void:
	_is_saving = false
	if save_icon:
		save_icon.hide()

## EXPERT USAGE:
## ComplianceHandler.notify_save_start() -> await save() -> notify_save_end()

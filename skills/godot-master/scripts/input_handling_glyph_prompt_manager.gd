# glyph_prompt_manager.gd
# Dynamic UI prompt switching (Keyboard vs Gamepad) [25]
extends Node

signal device_changed(type: String)

enum Device { KEYBOARD_MOUSE, GAMEPAD }
var last_device: Device = Device.KEYBOARD_MOUSE

func _input(event: InputEvent) -> void:
	var current: Device = last_device
	
	if event is InputEventKey or event is InputEventMouseButton:
		current = Device.KEYBOARD_MOUSE
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		current = Device.GAMEPAD
		
	if current != last_device:
		last_device = current
		device_changed.emit("GamePad" if current == Device.GAMEPAD else "KBM")

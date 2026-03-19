class_name BaseMenu
extends Control

## Expert foundation for all UI menus.
## Handles focus persistence, animations, and input blocking.

signal menu_closed

@onready var first_focus_node: Control = null

func open_menu() -> void:
	show()
	_on_menu_opened()
	if first_focus_node:
		first_focus_node.grab_focus()

func close_menu() -> void:
	hide()
	menu_closed.emit()
	_on_menu_closed()

## Virtual hooks for juice (animations/sounds)
func _on_menu_opened() -> void:
	pass

func _on_menu_closed() -> void:
	pass

## Expert: Handle 'ui_cancel' (Escape/B) natively to close menus
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and is_visible_in_tree():
		close_menu()
		get_viewport().set_input_as_handled()

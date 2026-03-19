# callable_binding_context.gd
# Injecting extra data into callbacks using bind()
extends Node

func _ready() -> void:
	for i in range(5):
		var btn = Button.new()
		# When clicked, _on_button_pressed will receive 'i' as an argument
		btn.pressed.connect(_on_button_pressed.bind(i))
		add_child(btn)

func _on_button_pressed(index: int) -> void:
	print("Clicked button number: ", index)

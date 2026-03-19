# unbind_signal_args.gd
# Discarding unneeded signal arguments safely
extends Node

func _ready() -> void:
	# Some signals (like area_entered) pass an argument.
	# unbind(1) tells Godot to drop that argument before calling our function.
	$Area2D.area_entered.connect(_on_generic_event.unbind(1))

func _on_generic_event() -> void:
	print("Something entered the area, but I didn't need its reference.")

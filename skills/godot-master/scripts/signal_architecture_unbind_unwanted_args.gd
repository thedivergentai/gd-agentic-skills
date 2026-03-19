# unbind_unwanted_args.gd
# Cleaning up function signatures by discarding signal data
extends Node

func _ready():
	# area_entered emits 1 argument (the area).
	# unbind(1) drops it so we can use a simpler function.
	$Area2D.area_entered.connect(_play_chime.unbind(1))

func _play_chime():
	# This function doesn't need to know WHICH area entered.
	$AudioStreamPlayer.play()

# performance_character_pooling.gd
# Managing 100+ active character bodies via visibility
extends CharacterBody2D

# EXPERT NOTE: Characters off-screen should not run physics.

func _physics_process(_delta: float) -> void:
	# In built-in Godot, use VisibleOnScreenNotifier2D to 
	# toggle 'set_physics_process(false)'
	pass

func _on_screen_entered():
	set_physics_process(true)

func _on_screen_exited():
	set_physics_process(false)

# performance_batch_mover.gd
# Moving 100+ StaticBody2Ds without performance tanking
extends Node2D

# PROBLEM: Moving many StaticBody2Ds per frame is expensive.
# SOLUTION: Disable collision while moving or use AnimatableBody2D 
# which is optimized for code-driven movement.

@onready var platforms: Array = get_children().filter(func(c): return c is AnimatableBody2D)

func _physics_process(delta: float) -> void:
	for p in platforms:
		# AnimatableBody2D correctly calculates velocity for riders
		p.position.x += 100 * delta * sin(Time.get_ticks_msec() / 1000.0)

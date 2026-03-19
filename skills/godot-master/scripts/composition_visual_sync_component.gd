# visual_sync_component.gd
# Separating logic from visuals
class_name VisualSyncComponent extends Node

# EXPERT NOTE: This component syncs a Sprite or Mesh to the 
# parent's logical state (e.g., flipping based on velocity).

@export var sprite: Sprite2D
@export var velocity_component: VelocityComponent

func _process(_delta: float) -> void:
	if sprite and velocity_component:
		if velocity_component.velocity.x != 0:
			sprite.flip_h = velocity_component.velocity.x < 0

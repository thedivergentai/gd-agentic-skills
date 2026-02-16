class_name BouncyEggComponent
extends RigidBody3D

## A RigidBody that wobbles like an egg.
## Requires a collision shape.

@export var wobble_strength: float = 0.5
@export var squash_factor: float = 0.2

var _original_scale: Vector3

func _ready() -> void:
	_original_scale = scale
	# Offset center of mass to make it bottom-heavy (classic wobble)
	center_of_mass = Vector3(0, -0.3, 0)
	
	body_entered.connect(_on_impact)
	contact_monitor = true
	max_contacts_reported = 1

func _on_impact(body: Node) -> void:
	# Squash and stretch on impact
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	
	# Scale down Y (squash), Scale up X/Z (stretch)
	var squash_scale = _original_scale * Vector3(1.0 + squash_factor, 1.0 - squash_factor, 1.0 + squash_factor)
	
	tween.tween_property(self, "scale", squash_scale, 0.1)
	tween.tween_property(self, "scale", _original_scale, 0.4)

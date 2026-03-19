class_name RevivalSoulGrave
extends Node3D

## Expert Soul Retrieval (Dark Souls style).
## Persistence object left at death site containing lost resources.

var lost_currency: int = 0

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		if body.has_method("add_currency"):
			body.add_currency(lost_currency)
		queue_free()

## Rule: Ensure graves are spawned slightly above the ground offset to avoid physics clipping.

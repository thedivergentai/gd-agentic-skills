# Volumetric Fog Transition Zones
extends FogVolume

## Smoothly transitioning fog density as the player enters a localized area
## like a cave or a dense forest patch.

func _on_body_entered(body: Node3D) -> void:
    if body is CharacterBody3D:
        var tween = create_tween()
        # Fade density from global environment value to local volume value
        tween.tween_property(self, "density", 1.5, 2.0)

func _on_body_exited(body: Node3D) -> void:
    if body is CharacterBody3D:
        var tween = create_tween()
        tween.tween_property(self, "density", 0.0, 1.0)

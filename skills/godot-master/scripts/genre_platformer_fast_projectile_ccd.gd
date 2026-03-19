# fast_projectile_ccd.gd
extends RigidBody2D
class_name FastProjectileCCD

# Continuous Collision Detection (CCD) for High-Speed Sprites
# Prevents "tunneling" through thin geometry.

func _ready() -> void:
    # Pattern: Use ray-casting CD for extremely fast, small bullets/sprites.
    continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
    max_contacts_reported = 1
    contact_monitor = true

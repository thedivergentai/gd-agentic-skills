# synchronized_platform.gd
extends AnimatableBody2D
class_name SynchronizedPlatform

# Synchronized Moving Platform
# Ensures platforms move flawlessly in sync with the physics tick.

func _ready() -> void:
    # Pattern: Mandatory for platforms moved by AnimationPlayer/Tweens.
    sync_to_physics = true

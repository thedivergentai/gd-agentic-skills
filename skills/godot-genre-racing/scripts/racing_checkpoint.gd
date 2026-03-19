# racing_checkpoint.gd
extends Area3D
class_name RacingCheckpoint

# Sequential Checkpoint Validation Gate
# Signal-based tracker for lap progression.

@export var checkpoint_index := 0
signal crossed(node: Node3D, idx: int)

func _on_body_entered(body: Node3D) -> void:
    if body.is_in_group(&"player"):
        crossed.emit(body, checkpoint_index)

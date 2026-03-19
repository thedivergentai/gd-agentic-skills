class_name RevivalCheckpointValidator
extends Area3D

## Expert Checkpoint Validator.
## Ensures players can't downgrade their progress index.

@export var checkpoint_id: String = ""
@export var progress_index: int = 0

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("Player"):
		var current_progress = RevivalGlobalManager.get_progress()
		if progress_index >= current_progress:
			RevivalGlobalManager.set_active_checkpoint(global_position, checkpoint_id, progress_index)

## Rule: Always use a 'Progress Index' to prevent backtracking from overriding endgame checkpoints.

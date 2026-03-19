class_name RevivalAutoSaveManager
extends Node

## Expert Auto-Save Bridge.
## Triggers the global Save System when a new checkpoint is reached.

func _on_checkpoint_activated() -> void:
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").save_game()
		print("Checkpoint Auto-Saved.")

## Rule: In modern ARPGs/Platformers, checkpoints should ALWAYS trigger an auto-save.

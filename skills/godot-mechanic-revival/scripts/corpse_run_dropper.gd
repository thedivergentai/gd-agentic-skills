class_name CorpseRunDropper
extends Node

## Spawns a physical object ("Grave") at the death location containing % of lost currency.
## Designed for Souls-like games.

@export var grave_scene: PackedScene
@export var currency_loss_percentage: float = 1.0 # 1.0 = 100% loss

# Connect this to your player's death signal manually or via signal bus.
func on_player_death(player_position: Vector3, current_currency: int) -> int:
	if not grave_scene:
		push_warning("CorpseRunDropper: No grave_scene assigned.")
		return current_currency # Return without modifying
		
	var lost_amount = int(current_currency * currency_loss_percentage)
	var remaining = current_currency - lost_amount
	
	_spawn_grave(player_position, lost_amount)
	
	return remaining

func _spawn_grave(pos: Vector3, amount: int) -> void:
	if amount <= 0:
		return
		
	var grave = grave_scene.instantiate()
	
	# Safety Check: Ensure the scene actually supports our "Grave" protocol
	if not grave.has_method("setup"):
		push_error("CorpseRunDropper: Grave scene '%s' does not have a 'setup(amount)' method!" % grave_scene.resource_path)
		grave.queue_free()
		return

	# Add to main scene root so it persists after player respawn (if player is reloaded)
	# Usually, levels persist, so this is fine.
	get_tree().current_scene.add_child(grave)
	grave.global_position = pos
	
	grave.setup(amount)

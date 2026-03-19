class_name NetAuthServerValidator
extends Node

## Expert Server-Authoritative Anti-Cheat.
## Validates movement and actions before broadcasting.

const MAX_SPEED = 15.0
const SPEED_BUFFER = 1.1

func validate_move(player: Node3D, new_pos: Vector3, delta: float) -> bool:
	var dist = player.global_position.distance_to(new_pos)
	var max_dist = MAX_SPEED * delta * SPEED_BUFFER
	
	if dist > max_dist:
		printerr("Cheat detected: Player moved too fast!")
		return false
	return true

## Rule: Never trust client-reported health or inventory values. Calculate them on server.

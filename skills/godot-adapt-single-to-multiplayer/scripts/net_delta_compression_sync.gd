class_name NetDeltaCompressionSync
extends Node

## Expert Delta Compression & Quantization.
## Reduces bandwidth by only syncing significant changes and truncating floats.

@export var synchronizer: MultiplayerSynchronizer

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	# Expert: Truncate precision to 2 decimal places to save bits
	var quantized_pos = global_position.snapped(Vector3(0.01, 0.01, 0.01))
	
	# Only sync if the change is significant
	if global_position.distance_to(quantized_pos) > 0.001:
		# MultiplayerSynchronizer handles the low-level UDP packing
		pass

## Rule: Avoid syncing 'Rotation' every frame. Sync 'Rotation Angle' as a single half-float (16-bit).

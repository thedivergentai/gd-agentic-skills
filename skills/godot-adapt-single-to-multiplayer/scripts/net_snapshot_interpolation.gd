class_name NetSnapshotInterpolation
extends Node3D

## Expert Snapshot Interpolation.
## Smooths other peers' movement by lerping between past snapshots.

var snapshots: Array[Dictionary] = []
const INTERP_DELAY_MS = 100

func _process(_delta: float) -> void:
	if is_multiplayer_authority(): return
	
	var render_time = Time.get_ticks_msec() - INTERP_DELAY_MS
	
	# Find two snapshots for the 'render_time'
	if snapshots.size() >= 2:
		var s1 = snapshots[0]
		var s2 = snapshots[1]
		# Lerp position between s1 and s2...
		global_position = s1.pos.lerp(s2.pos, 0.1)

@rpc("authority", "call_remote", "unreliable")
func update_state(pos: Vector3) -> void:
	snapshots.append({"time": Time.get_ticks_msec(), "pos": pos})
	if snapshots.size() > 5: snapshots.pop_front()

## Rule: Never snap peers to raw values. Always use a jitter-buffer/delay.

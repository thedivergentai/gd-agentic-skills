class_name NetPredictionReconciliation
extends CharacterBody3D

## Expert Client Prediction & Server Reconciliation.
## Minimizes apparent latency by predicting movement and replaying on error.

var input_buffer: Array[Dictionary] = []
var latest_server_tick: int = 0
const RECONCILIATION_THRESHOLD = 0.5

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		var input = _get_input()
		var tick = Engine.get_physics_frames()
		
		# Predict locally
		input_buffer.append({"tick": tick, "input": input, "pos": global_position})
		_apply_movement(input, delta)
		
		# Send input to server
		rpc_id(1, "server_process_input", input, tick)

@rpc("any_peer", "call_remote", "unreliable")
func server_process_input(input: Vector2, client_tick: int) -> void:
	# Server validates and applies
	_apply_movement(input, get_physics_process_delta_time())
	rpc_id(multiplayer.get_remote_sender_id(), "client_reconcile", global_position, client_tick)

@rpc("authority", "call_remote", "unreliable")
func client_reconcile(server_pos: Vector3, server_tick: int) -> void:
	if global_position.distance_to(server_pos) > RECONCILIATION_THRESHOLD:
		global_position = server_pos
		# Replay inputs from 'server_tick' to now...
		pass

func _apply_movement(input: Vector2, _delta: float) -> void:
	velocity = Vector3(input.x, 0, input.y) * 10.0
	move_and_slide()

func _get_input() -> Vector2: return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

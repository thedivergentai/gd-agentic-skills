# godot-master/scripts/multiplayer_networking_server_authoritative_controller.gd
extends CharacterBody2D

## Server Authoritative Controller Expert Pattern
## Client-side prediction with server reconciliation and interpolation.

class_name ServerAuthoritativeController

@export var speed := 300.0
@export var interpolation_factor := 20.0

# Network State
@export var network_position: Vector2
@export var last_processed_input_id: int

# Client Prediction
var _input_queue: Array[Dictionary] = []
var _pending_inputs: Array[Dictionary] = []
var _input_id_counter: int = 0

func _ready() -> void:
	# Configure synchronizer if separate, or use built-in
	pass

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		_process_client(delta)
	else:
		_process_puppet(delta)

func _process_client(delta: float) -> void:
	# 1. Gather Input
	var input = _get_input()
	input["id"] = _input_id_counter
	input["delta"] = delta
	_input_id_counter += 1
	
	# 2. Predict locally
	velocity = input["velocity"]
	move_and_slide()
	
	# 3. Store for reconciliation
	_pending_inputs.append({
		"id": input["id"],
		"position": global_position,
		"input": input
	})
	
	# 4. Send to server
	send_input.rpc_id(1, input)

func _process_puppet(delta: float) -> void:
	# Interpolate to authoritative position
	global_position = global_position.lerp(network_position, interpolation_factor * delta)

@rpc("any_peer", "call_remote", "unreliable")
func send_input(input_data: Dictionary) -> void:
	# Server side execution
	if not multiplayer.is_server(): return
	
	# Validation could happen here
	velocity = input_data["velocity"]
	move_and_slide()
	
	network_position = global_position
	last_processed_input_id = input_data["id"]
	
	# Broadcast specific state to owner for reconciliation
	receive_state.rpc_id(multiplayer.get_remote_sender_id(), network_position, last_processed_input_id)
	
	# Broadcast world state to others (via Synchronizer usually, or manual RPC)
	# sync_to_others.rpc(network_position)

@rpc("authority", "call_remote", "unreliable")
func receive_state(server_pos: Vector2, last_input_id: int) -> void:
	# Client Reconciliation
	# Remove inputs processed by server
	_pending_inputs = _pending_inputs.filter(func(i): return i.id > last_input_id)
	
	if _pending_inputs.is_empty():
		global_position = server_pos
		return

	# If server position deviates too much from our history at that simplified input id
	# (Simplified logic: just snap and replay)
	global_position = server_pos
	
	# Replay remaining inputs
	for history in _pending_inputs:
		velocity = history.input["velocity"]
		move_and_slide()
		# Update history record
		history["position"] = global_position

func _get_input() -> Dictionary:
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	return {"velocity": dir * speed}

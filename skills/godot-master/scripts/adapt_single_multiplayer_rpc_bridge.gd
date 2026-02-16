# godot-master/scripts/adapt_single_multiplayer_rpc_bridge.gd
extends Node

## RPC Bridge Expert Pattern
## Signal-to-RPC bridge for centralized networking logic.
## Decouples network transport from game logic.

class_name RPCBridge

# Define network events
signal input_received(peer_id: int, input: Vector2)
signal state_updated(peer_id: int, state: Dictionary)
signal event_occurred(event_name: String, data: Dictionary)

# RPC wrappers
@rpc("any_peer", "call_remote", "unreliable")
func send_input(input: Vector2) -> void:
    var sender_id = multiplayer.get_remote_sender_id()
    # Validate Authority: Server Logic
    if multiplayer.is_server():
        input_received.emit(sender_id, input)

@rpc("authority", "call_remote", "unreliable")
func update_client_state(state: Dictionary) -> void:
    # Client Logic
    state_updated.emit(1, state)

@rpc("any_peer", "call_remote", "reliable")
func broadcast_event(name: String, data: Dictionary) -> void:
    # Server guard
    if multiplayer.is_server():
        # Re-broadcast to valid listeners
        _client_receive_event.rpc(name, data)
        event_occurred.emit(name, data) # Server handles it too

@rpc("authority", "call_remote", "reliable")
func _client_receive_event(name: String, data: Dictionary) -> void:
    event_occurred.emit(name, data)

# Public API
func submit_input(input: Vector2) -> void:
    if multiplayer.has_multiplayer_peer():
        send_input.rpc_id(1, input)
    else:
        # Offline fallback
        input_received.emit(1, input)

func push_state_update(peer_id: int, state: Dictionary) -> void:
    if multiplayer.is_server():
        update_client_state.rpc_id(peer_id, state)

func trigger_event(name: String, data: Dictionary) -> void:
    if multiplayer.is_server():
        _client_receive_event.rpc(name, data)
        event_occurred.emit(name, data)
    elif multiplayer.has_multiplayer_peer():
        broadcast_event.rpc_id(1, name, data)

## EXPERT USAGE:
## Use this bridge to avoid littering @rpc functions inside every Actor.
## connect("input_received", _on_input) in your ServerController.

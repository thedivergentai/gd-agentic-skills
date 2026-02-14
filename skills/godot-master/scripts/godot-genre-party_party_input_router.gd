# skills/genre-party/code/party_input_router.gd
extends Node

## Party Input Router Expert Pattern
## Isolates inputs for 4 local players using device-ID prefixing.

signal player_joined(player_id: int, device_id: int)
signal player_input_received(player_id: int, action: String, strength: float)

var _player_assignments: Dictionary = {} # player_id -> device_id

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventJoypadButton or event is InputEventJoypadMotion:
        var device_id = event.device
        
        # 1. Join Logic
        if event.is_action_pressed("ui_accept"):
            _handle_join_request(device_id)
            
        # 2. Input Isolation
        var player_id = _get_player_from_device(device_id)
        if player_id != -1:
            _route_input(player_id, event)

func _handle_join_request(device_id: int) -> void:
    if device_id not in _player_assignments.values():
        var new_player_id = _player_assignments.size() + 1
        if new_player_id <= 4:
            _player_assignments[new_player_id] = device_id
            player_joined.emit(new_player_id, device_id)
            print("Player ", new_player_id, " Joined on Device ", device_id)

func _get_player_from_device(device_id: int) -> int:
    for p_id in _player_assignments:
        if _player_assignments[p_id] == device_id:
            return p_id
    return -1

func _route_input(player_id: int, event: InputEvent) -> void:
    # 3. Action Prefixing
    # In a professional party game, you shouldn't just check 'Input.is_action_pressed'.
    # You must map the device-specific events to player-abstracted signals.
    
    # Placeholder for action-mapping logic
    # var action_name = _map_event_to_action(event)
    # player_input_received.emit(player_id, action_name, event.get_action_strength(action_name))
    pass

## EXPERT NOTE:
## Use 'InputMap.action_add_event()' at runtime to dynamically create 
## "p1_jump", "p2_jump" actions maped to specific Device IDs. 
## NEVER share a single "jump" action across players in local multiplayer.

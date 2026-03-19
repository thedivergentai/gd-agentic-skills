# player_join_manager.gd
extends Node
class_name PlayerJoinManager

# Dynamic Player "Join" System (Local Multiplayer)
# Listens for any controller pressing "Start" and assigns device IDs.

signal player_joined(player_index: int, device_id: int)

var active_players: Dictionary = {} # Maps player_index (0-3) to device_id
var max_players := 4

func _unhandled_input(event: InputEvent) -> void:
    # Pattern: Use raw InputEventJoypadButton to identify the EXACT physical device.
    if event is InputEventJoypadButton and event.is_pressed() and not event.is_echo():
        if not active_players.values().has(event.device):
            if active_players.size() < max_players:
                var next_player_index = active_players.size()
                active_players[next_player_index] = event.device
                player_joined.emit(next_player_index, event.device)
                
                # Mark as handled to prevent multiple joins from one press.
                get_viewport().set_input_as_handled()

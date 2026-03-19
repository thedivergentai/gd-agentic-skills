# connection_monitor.gd
extends Node
class_name ConnectionMonitor

# Controller Disconnect Handling
# Pauses the game if a controller battery dies mid-minigame.

func _ready() -> void:
    Input.joy_connection_changed.connect(_on_joy_changed)

func _on_joy_changed(device: int, connected: bool) -> void:
    if not connected:
        # Cross-reference with active tournament players.
        # if TournamentState.active_players.values().has(device):
        get_tree().paused = true
        # Notify UI to show reconnect prompt.
        get_tree().call_group(&"ui_overlays", &"show_reconnect", device)

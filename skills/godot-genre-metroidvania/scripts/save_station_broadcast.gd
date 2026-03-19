# save_station_broadcast.gd
extends Area2D
class_name SaveStationBroadcast

# Broadcasting Save Station Events
# Uses Godot groups to reset enemies and world state without manual iteration.

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group(&"player"):
        _trigger_save_routine(body)

func _trigger_save_routine(player: Node2D) -> void:
    # 1. Broadly reset all entities in the 'enemies' group.
    get_tree().call_group(&"enemies", &"respawn")
    
    # 2. Heal the player via duck-typing to avoid hard dependencies.
    if player.has_method(&"heal_to_full"):
        player.call(&"heal_to_full")
    
    # 3. Trigger persistent save logic.
    # SaveManager.save_game()
    pass

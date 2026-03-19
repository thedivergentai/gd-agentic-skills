# puzzle_saver.gd
extends Node
class_name PuzzleSaver

# Saving Persistent Puzzle State
# Serializes object properties safely into the user:// directory.

func save_game(save_name: String = "puzzle_save.json") -> void:
    var save_dict := {}
    var save_nodes := get_tree().get_nodes_in_group("Persist")
    
    for node in save_nodes:
        save_dict[node.name] = {
            # Pattern: Manually split complex types (Vector2) for JSON.
            "pos_x": node.position.x,
            "pos_y": node.position.y,
            "state": node.get("puzzle_state") if "puzzle_state" in node else 0
        }
        
    var path := "user://" + save_name
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file:
        file.store_line(JSON.stringify(save_dict))

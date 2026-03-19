# puzzle_history.gd
extends Node
class_name PuzzleHistory

# Action Command Pattern (Undo/Redo System)
# Robust undo history keeping "do" and "undo" methods strictly separated.

var undo_redo := UndoRedo.new()

func execute_move(node: Node2D, target_position: Vector2) -> void:
    undo_redo.create_action("Move Piece")
    
    # Expert Pattern: Group 'do' on one side and 'undo' on the other.
    undo_redo.add_do_property(node, "position", target_position)
    undo_redo.add_undo_property(node, "position", node.position)
    
    undo_redo.commit_action()

func undo_last_move() -> void:
    if undo_redo.has_undo():
        undo_redo.undo()

func redo_last_move() -> void:
    if undo_redo.has_redo():
        undo_redo.redo()

# skills/genre-puzzle/scripts/command_undo_redo.gd
class_name CommandUndoRedo
extends Node

## Command Pattern Undo/Redo System (Expert Pattern)
## Manages a history of commands to allow unlimited undo/redo functionality.

signal state_changed(can_undo: bool, can_redo: bool)

var history: Array[Command] = []
var history_index: int = -1
const MAX_HISTORY: int = 100

# Abstract Command Class
class Command extends RefCounted:
    func execute() -> void: pass
    func undo() -> void: pass

func commit_command(cmd: Command) -> void:
    # If we are in the middle of history, clear the future
    if history_index < history.size() - 1:
        history = history.slice(0, history_index + 1)
    
    cmd.execute()
    history.append(cmd)
    
    if history.size() > MAX_HISTORY:
        history.pop_front()
    else:
        history_index += 1
        
    _emit_state()

func undo() -> void:
    if history_index >= 0:
        history[history_index].undo()
        history_index -= 1
        _emit_state()

func redo() -> void:
    if history_index < history.size() - 1:
        history_index += 1
        history[history_index].execute()
        _emit_state()

func clear_history() -> void:
    history.clear()
    history_index = -1
    _emit_state()

func _emit_state() -> void:
    state_changed.emit(history_index >= 0, history_index < history.size() - 1)

## EXPERT USAGE:
## Define subclasses of Command (e.g. MoveCommand).
## Instantiate and pass to commit_command().

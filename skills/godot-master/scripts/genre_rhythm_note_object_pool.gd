# note_object_pool.gd
extends Node
class_name NoteObjectPool

# High-Frequency Entity Recycling
# Pre-instantiates notes to avoid frame drops during busy sequences.

@export var note_scene: PackedScene
@export var pool_size := 50
var _pool: Array[Node] = []

func _ready() -> void:
    for i in pool_size:
        var note = note_scene.instantiate()
        note.hide()
        note.process_mode = PROCESS_MODE_DISABLED
        add_child(note)
        _pool.append(note)

func get_note() -> Node:
    # Pattern: Fetch disabled nodes from the pool and reactive them.
    for note in _pool:
        if not note.visible:
            note.show()
            note.process_mode = PROCESS_MODE_INHERIT
            return note
    return null

# ghost_recorder.gd
extends Node
class_name GhostRecorder

# Ghost Car Recording (Compact Serialization)
# Caches position and rotation at intervals for low-memory replay loops.

var recording: Array[Dictionary] = []
var record_interval := 0.1
var time_since_last_record := 0.0

func _physics_process(delta: float) -> void:
    time_since_last_record += delta
    if time_since_last_record >= record_interval:
        time_since_last_record = 0.0
        _record_snapshot()

func _record_snapshot() -> void:
    var parent = get_parent() as Node3D
    if not parent: return
    
    recording.append({
        "p": parent.global_position,
        "r": parent.global_quaternion
    })

func save_ghost(path: String) -> void:
    var file = FileAccess.open(path, FileAccess.WRITE)
    # Pattern: Use binary store_var for speed and compactness.
    file.store_var(recording)
    file.close()

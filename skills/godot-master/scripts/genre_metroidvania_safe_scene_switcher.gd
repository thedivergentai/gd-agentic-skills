# safe_scene_switcher.gd
extends Node
class_name SafeSceneSwitcher

# Safe Deferred Scene Transitions
# Prevents engine crashes by ensuring scene changes happen between frames.

func goto_room(path: String) -> void:
    # Pattern: ALWAYS defer scene switches to avoid flushing nodes mid-execution.
    call_deferred(&"_deferred_goto_room", path)

func _deferred_goto_room(path: String) -> void:
    # Safely dispose of previous world before switching.
    if get_tree().current_scene:
        get_tree().current_scene.free()
        
    var next_scene := ResourceLoader.load(path) as PackedScene
    if next_scene:
        var instance := next_scene.instantiate()
        get_tree().root.add_child(instance)
        get_tree().current_scene = instance

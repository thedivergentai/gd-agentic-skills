# deferred_scene_switcher.gd
extends Node
class_name DeferredSceneSwitcher

# Safe Deferred Scene Switcher
# Transitions between minigames without crashing due to logic mid-execution.

func switch_to_hub(path: String) -> void:
    # NEVER free a scene immediately during its own logic execution.
    call_deferred(&"_deferred_switch", path)

func _deferred_switch(path: String) -> void:
    if get_tree().current_scene:
        get_tree().current_scene.free()
        
    var next := ResourceLoader.load(path) as PackedScene
    var inst := next.instantiate()
    get_tree().root.add_child(inst)
    get_tree().current_scene = inst

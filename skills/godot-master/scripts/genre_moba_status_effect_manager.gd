# status_effect_manager.gd
extends Node
class_name StatusEffectManager

# Applying Status Effects Safely
# Manages active buffs without modifying original globally shared resources.

var active_effects: Array[StatusEffectData] = []

func apply_effect(base_effect: StatusEffectData) -> void:
    if not base_effect: return
    
    # Pattern: Use duplicate() to ensure unique state for this instance.
    # Modifying duration/stacks on one unit won't affect others.
    var unique_instance := base_effect.duplicate() as StatusEffectData
    active_effects.append(unique_instance)
    _on_effect_added(unique_instance)

func _on_effect_added(_effect: StatusEffectData) -> void:
    # Trigger logic like slowing speed or initiating stuns.
    pass

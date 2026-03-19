# fog_claus_intensifier.gd
extends Node

# Dynamically Adjusting Volumetric Fog (Dread Atmosphere)
# Increases the claustrophobia effect by manipulating environment density in real-time.
func intensify_fog(env: Environment, target_density: float = 0.15) -> void:
    # Set this to the lowest base density you want globally.
    var current_density := env.volumetric_fog_density
    var tween := create_tween().set_trans(Tween.TRANS_SINE)
    
    # Smoothly increase density over time to signal increasing danger or psychological shifts.
    tween.tween_property(env, "volumetric_fog_density", current_density + target_density, 5.0)

# skills/genre-horror/scripts/sanity_manager.gd
extends Node

## Sanity Manager (Expert Pattern)
## Tracks sanity and applies global effects (audio distortion, camera shake).

class_name SanityManager

@export var max_sanity: float = 100.0
@export var decay_rate: float = 0.5
@export var world_environment: WorldEnvironment
@export var player_camera: Camera3D

var current_sanity: float = 100.0

func _process(delta: float) -> void:
    # Decay when in darkness (example logic)
    current_sanity -= decay_rate * delta
    current_sanity = clamp(current_sanity, 0.0, max_sanity)
    
    _apply_effects()

func _apply_effects() -> void:
    var stress_factor = 1.0 - (current_sanity / max_sanity)
    
    # 1. Audio Distortion (Low Pass)
    var bus_idx = AudioServer.get_bus_index("Master")
    var effect = AudioServer.get_bus_effect(bus_idx, 0) # Assumes Effect 0 is LowPass/Distortion
    if effect is AudioEffectLowPassFilter:
        effect.cutoff_hz = lerp(20000.0, 500.0, stress_factor)
        
    # 2. Camera Shake (Continuous jitter)
    if player_camera and stress_factor > 0.5:
        var shake = (stress_factor - 0.5) * 0.1
        player_camera.h_offset = randf_range(-shake, shake)
        player_camera.v_offset = randf_range(-shake, shake)
    else:
        if player_camera:
            player_camera.h_offset = 0
            player_camera.v_offset = 0

func recover(amount: float) -> void:
    current_sanity += amount

## EXPERT USAGE:
## Add AudioEffectLowPassFilter to Master bus slot 0.
## Adjust decay logic based on light/proximity to monsters.

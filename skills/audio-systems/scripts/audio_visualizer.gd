# skills/audio-systems/code/audio_visualizer.gd
extends Node

## Real-Time FFT Visualization Expert Pattern
## Technical blueprints for driving visuals based on audio peaks.

@onready var spectrum = AudioServer.get_bus_effect_instance(0, 0) # Master bus, index 0

func _process(_delta: float) -> void:
    if not spectrum: return
    
    # 1. Capture Frequency Ranges
    var low = spectrum.get_magnitude_for_frequency_range(20, 150)
    var mid = spectrum.get_magnitude_for_frequency_range(150, 2000)
    var high = spectrum.get_magnitude_for_frequency_range(2000, 20000)
    
    # 2. Normalize and drive VEFX (Visual Effects)
    var energy = (low.length() + mid.length() + high.length()) / 3.0
    _update_world_lighting(energy)

func _update_world_lighting(power: float) -> void:
    # Expert: Drive a shader parameter or light energy
    # SceneRoot.set_shader_parameter("audio_pulse", power)
    pass

## WHY THIS WAY?
## Spectral analysis allows for organic, rhythm-synced gameplay 
## (e.g. lights flashing on the beat) without manual keyframing.

# engine_audio_controller.gd
extends AudioStreamPlayer3D
class_name EngineAudioController

# Engine Audio Simulation (Pitch-Based RPM)
# Maps vehicle speed/RPM to audio pitch for realistic revving.

@export var min_pitch := 0.5
@export var max_pitch := 2.5
@export var speed_scale := 0.05

func update_engine_sound(current_speed: float) -> void:
    # Pattern: Calculate pitch based on speed/RPM curve.
    var target_pitch = min_pitch + (current_speed * speed_scale)
    pitch_scale = lerp(pitch_scale, clamp(target_pitch, min_pitch, max_pitch), 0.1)

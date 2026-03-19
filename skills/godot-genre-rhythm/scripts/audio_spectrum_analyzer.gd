# audio_spectrum_analyzer.gd
extends Node
class_name AudioSpectrumAnalyzer

# FFT-Based Visual Reactive Data
# Uses Godot's optimized spectrum analyzer effect for visuals.

var spectrum_analyzer: AudioEffectSpectrumAnalyzerInstance

func _ready() -> void:
    # Pattern: Get the instance from an existing Bus effect.
    spectrum_analyzer = AudioServer.get_bus_effect_instance(0, 0) # Master bus, index 0

func get_magnitude(from_hz: float, to_hz: float) -> float:
    if spectrum_analyzer:
        var magnitude = spectrum_analyzer.get_magnitude_for_frequency_range(from_hz, to_hz)
        return magnitude.length()
    return 0.0

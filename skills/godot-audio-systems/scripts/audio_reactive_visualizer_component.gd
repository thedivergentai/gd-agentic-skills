class_name AudioReactiveVisualizer
extends Node

## Expert spectrum-driven visualizer.
## Extracts magnitude from frequency ranges (Bass/Mid/High).

var spectrum: AudioEffectSpectrumAnalyzerInstance

func _ready() -> void:
	spectrum = AudioServer.get_bus_effect_instance(0, 0) # Index 0 of Master Bus

func get_bass_magnitude() -> float:
	var mag = spectrum.get_magnitude_for_frequency_range(20, 150)
	return mag.length()

## Tip: Use 'magnitude' to drive shader uniforms or light energy for audio-reactivity.

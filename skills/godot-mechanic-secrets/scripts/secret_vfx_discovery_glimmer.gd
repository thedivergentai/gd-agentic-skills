class_name SecretDiscoveryGlimmer
extends Node3D

## Expert Discovery 'Glimmer' VFX.
## A subtle visual cue for hidden objects that only appears occasionally.

@export var glimmer_light: OmniLight3D
@export var glimmer_frequency: float = 10.0 # Seconds between glimmers

func _ready() -> void:
	_glimmer_loop()

func _glimmer_loop() -> void:
	while true:
		await get_tree().create_timer(glimmer_frequency + randf_range(-2, 2)).timeout
		var tween = create_tween()
		tween.tween_property(glimmer_light, "light_energy", 2.0, 0.5)
		tween.tween_property(glimmer_light, "light_energy", 0.0, 0.5)

## Tip: Use 'Random Offset' in frequencies to make glimmers feel more organic and less mechanical.

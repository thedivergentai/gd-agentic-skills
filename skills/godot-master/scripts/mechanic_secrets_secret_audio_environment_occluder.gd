class_name SecretAudioOccluder
extends Area3D

## Expert Secret Room Audio Occlusion.
## Modifies AudioBus effects (e.g. Muffle/Reverb) when entering secret areas.

@export var target_bus: String = "Master"
@export var effect_index: int = 0 # E.g. LowPassFilter

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index(target_bus), effect_index, true)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index(target_bus), effect_index, false)

## Rule: Secret rooms should sound 'different' (e.g. vacuum-sealed or echoey) to enhance discovery.

class_name VRHapticSequencer
extends Node

## Expert haptic sequencer for VR controllers.
## Uses trigger_haptic_pulse to create distinct tactile patterns (Success, Impact).

func play_haptic_vibration(controller: XRController3D, amplitude: float = 0.5, duration: float = 0.1) -> void:
	if controller:
		# frequency, amplitude, duration, delay
		controller.trigger_haptic_pulse("haptic", 100.0, amplitude, duration, 0.0)

func play_triple_echo(controller: XRController3D) -> void:
	for i in range(3):
		play_haptic_vibration(controller, 0.2 + (i * 0.1), 0.05)
		await get_tree().create_timer(0.1).timeout

## Rule: Always use the 'haptic' action name defined in OpenXR settings.

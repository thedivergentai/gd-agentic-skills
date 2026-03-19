# player_haptic_feedback.gd
extends Node
class_name PlayerHapticFeedback

# Localized Haptic Feedback
# Triggers rumble strictly on the controller of the player who was hit.

func trigger_vibration(device_id: int, weak: float, strong: float, duration: float) -> void:
    # Pattern: Finite duration is mandatory to prevent infinite rumble on pause.
    if device_id != -1:
        Input.start_joy_vibration(device_id, weak, strong, duration)

func _on_eliminated(device_id: int) -> void:
    trigger_vibration(device_id, 1.0, 1.0, 0.5)

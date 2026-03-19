class_name AudioEnvironmentalReverbZone
extends Area3D

## Expert Area-based reverb management.
## Dynamically modifies bus reverb parameters when entering the zone.

@export var reverb_index: int = 0
@export var room_size: float = 0.8

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		var sfx_bus = AudioServer.get_bus_index("SFX")
		var reverb = AudioServer.get_bus_effect(sfx_bus, reverb_index) as AudioEffectReverb
		reverb.room_size = room_size

## Tip: Use multiple zones to smoothly transition a player between 'Cave' and 'Hall'.

class_name AudioBusDuckerLogic
extends Node

## Expert 'Sidechain' style Bus Ducking.
## Lowers music volume when a 'Hero' sound (SFX) is triggered.

@export var target_bus: String = "Music"
@export var trigger_bus: String = "Dialog"

func duck_bus(amount_db: float = -15.0, duration: float = 0.5) -> void:
	var bus_idx = AudioServer.get_bus_index(target_bus)
	var original_db = AudioServer.get_bus_volume_db(bus_idx)
	
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_method(func(v): AudioServer.set_bus_volume_db(bus_idx, v), original_db, amount_db, 0.1)
	tween.tween_interval(duration)
	tween.tween_method(func(v): AudioServer.set_bus_volume_db(bus_idx, v), amount_db, original_db, 0.5)

## Rule: Ducking is essential for clarity in narrative-heavy or loud combat games.

class_name AudioLinearVolumeInterpolator
extends Node

## Expert linear-to-db volume interpolation.
## Essential for smooth UI sliders that feel musically correct.

func set_linear_volume(bus_name: String, value: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	var db_value = linear_to_db(value)
	AudioServer.set_bus_volume_db(bus_idx, db_value)

## Rule: Volume sliders must ALWAYS use 'linear_to_db'. Constant DB change = Logarithmic feel.

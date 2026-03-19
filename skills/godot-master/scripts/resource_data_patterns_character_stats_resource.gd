# character_stats_resource.gd
# Reactive data containers using signals
class_name CharacterStats extends Resource

# EXPERT NOTE: Resources can emit signals! Use this to update 
# UI automatically when a stat value changes.

signal changed(property_name: String, new_val: Variant)

@export var level: int = 1:
	set(val):
		if level != val:
			level = val
			changed.emit("level", val)
			emit_changed() # Native Resource signal

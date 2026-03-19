# dynamic_stat_label_sync.gd
# UI hook for reactive stat displays
extends Label

# EXPERT NOTE: UI should listen for stats_recalculated 
# rather than polling in _process.

@export var stats: StatsComponent
@export var target_attribute: String = "strength"

func _ready():
	if stats:
		stats.stats_recalculated.connect(_update_display)
		_update_display()

func _update_display():
	text = "%s: %d" % [target_attribute.capitalize(), stats.get_attribute(target_attribute)]

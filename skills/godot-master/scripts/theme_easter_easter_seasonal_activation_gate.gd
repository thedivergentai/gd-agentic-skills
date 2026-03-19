class_name EasterSeasonalActivationGate
extends Node

## Expert date-aware activation manager.
## Automatically toggles seasonal content based on the system calendar.

@export var easter_content_root: Node

func _ready() -> void:
	var date := Time.get_date_dict_from_system()
	# Check if month is April (Month 4)
	var is_easter_season := (date.month == 4)
	
	if easter_content_root:
		easter_content_root.visible = is_easter_season
		print("Seasonal: Easter Content ", "ENABLED" if is_easter_season else "DISABLED")

## Rule: Always provide a 'Dev Override' flag to test seasonal content off-season.

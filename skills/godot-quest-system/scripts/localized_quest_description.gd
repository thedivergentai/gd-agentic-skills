# localized_quest_description.gd
# Strategy for translation-friendly quest text
extends Resource

# EXPERT NOTE: Use 'tr()' on IDs rather than hardcoding strings 
# inside the Resource files for professional localization support.

@export var title_key: String = "QUEST_01_TITLE"
@export var desc_key: String = "QUEST_01_DESC"

func get_title() -> String:
	return tr(title_key)

func get_desc() -> String:
	return tr(desc_key)

# harvest_tool_data.gd
# [GDSKILLS] godot-game-loop-harvest
# EXPORT_REFERENCE: harvest_tool_data.gd

extends Resource
class_name HarvestToolData

@export_group("Stats")
## Human-readable name (e.g., "Steel Axe").
@export var display_name: String = "Tool"
## The type of tool (e.g., "axe", "pickaxe").
@export var tool_type: String = "any"
## Damage dealt per hit to the resource.
@export var damage: int = 1
## Tier of the tool (0 = basic, 1 = advanced).
@export var tier: int = 0

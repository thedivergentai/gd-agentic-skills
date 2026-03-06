# game_loop_harvest_data.gd
# [GDSKILLS] godot-game-loop-harvest
# EXPORT_REFERENCE: resource_data.gd

extends Resource
class_name HarvestResourceData

@export_group("Stats")
## Human-readable name (e.g., "Iron Ore").
@export var display_name: String = "Resource"
## Number of hits required to harvest.
@export var health: int = 3
## Minimum/Maximum yield per harvest.
@export var yield_range: Vector2i = Vector2i(1, 3)

@export_group("Interaction")
## Required tool type to harvest this resource.
@export var required_tool_type: String = "any"
## The visual scene to instance (for items or effects).
@export var item_scene: PackedScene

@export_group("Respawn")
## Time in seconds before the node regrows.
@export var respawn_time: float = 60.0

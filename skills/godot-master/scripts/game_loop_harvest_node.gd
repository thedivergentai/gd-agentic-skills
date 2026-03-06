# game_loop_harvest_node.gd
# [GDSKILLS] godot-game-loop-harvest
# EXPORT_REFERENCE: harvestable_node.gd

extends StaticBody3D

signal harvested(data: HarvestResourceData, amount: int)
signal took_damage(current_health: int)

@export var resource_data: HarvestResourceData
var current_health: int

func _ready() -> void:
	if resource_data:
		current_health = resource_data.health

func apply_hit(damage: int, tool_type: String = "any") -> void:
	if resource_data.required_tool_type != "any" and tool_type != resource_data.required_tool_type:
		return
		
	current_health -= damage
	took_damage.emit(current_health)
	
	if current_health <= 0:
		_on_depleted()

func _on_depleted() -> void:
	var yield_amount = randi_range(resource_data.yield_range.x, resource_data.yield_range.y)
	harvested.emit(resource_data, yield_amount)
	
	# Logic for respawn manager to take over
	_hide_and_wait()

func _hide_and_wait() -> void:
	collision_layer = 16 # "Inactive" layer
	hide()
	await get_tree().create_timer(resource_data.respawn_time).timeout
	respawn()

func respawn() -> void:
	current_health = resource_data.health
	collision_layer = 1 # "World" layer
	show()

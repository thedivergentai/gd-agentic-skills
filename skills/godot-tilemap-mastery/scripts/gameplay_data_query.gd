# gameplay_data_query.gd
# Querying Custom Data Layers for gameplay logic (damage, speed) [181]
extends Node2D

@onready var ground_layer: TileMapLayer = $GroundLayer

func _physics_process(_delta: float) -> void:
	# Get tile under player position
	var map_pos = ground_layer.local_to_map(ground_layer.to_local(global_position))
	var data = ground_layer.get_cell_tile_data(map_pos)
	
	if data:
		# Expert: Use string keys from 'Custom Data Layers' setup in TileSet
		var surface_friction = data.get_custom_data("friction")
		var is_lava = data.get_custom_data("is_lava")
		
		_apply_surface_logic(surface_friction, is_lava)

func _apply_surface_logic(friction: float, lethal: bool) -> void:
	# Apply friction to movement or damage if lethal
	pass

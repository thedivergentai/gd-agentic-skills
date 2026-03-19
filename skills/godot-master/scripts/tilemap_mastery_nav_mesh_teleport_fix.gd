# nav_mesh_teleport_fix.gd
# Runtime Navigation updates for dynamic TileMap shifts [214]
extends TileMapLayer

# Godot 4 TileMapLayers can automatically bake navigation.

func update_nav_for_hole(map_pos: Vector2i) -> void:
	# Erasing a cell with a 'Navigation Layer' configured 
	# automatically updates the NavigationServer2D mesh.
	erase_cell(map_pos)
	
	# If results aren't immediate, force a sync:
	# NavigationServer2D.process_frame()
	
	print("Navigation path re-evaluating for hole at: ", map_pos)

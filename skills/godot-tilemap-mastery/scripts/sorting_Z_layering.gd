# sorting_Z_layering.gd
# Handling Y-sorting and Z-index layering for 2.5D [129]
extends TileMapLayer

# In Godot 4, TileMapLayer nodes can participate in Y-sorting.

func _ready() -> void:
	# Enable Y-sorting so children (players) correctly appear 
	# behind/in-front of trees or walls.
	y_sort_enabled = true
	
	# For multi-layered buildings:
	# Layer 1 (Ground): Z-Index 0
	# Layer 2 (Roof): Z-Index 10 + Y-Sort Disabled (always on top)
	
	# Runtime Z-Index modification for 'entering building' visuals
	z_index = -5 if is_underground else 0

# ShapeCast2D AOE Detection Patterns
extends ShapeCast2D

## Using ShapeCast2D for robust AOE detection. 
## Unlike Area2D, ShapeCast2D detects collisions at the EXACT moment of query.

func get_impact_entities(faction_mask: int) -> Array[Node2D]:
	collision_mask = faction_mask
	force_shapecast_update()
	
	var entities: Array[Node2D] = []
	for i in range(get_collision_count()):
		var col = get_collider(i)
		if col is Node2D:
			entities.append(col)
			
	return entities

# ledge_grab_sensor.gd
extends Node2D
class_name LedgeGrabSensor

# Ledge Grabbing using ShapeCast2D logic
# Performs a nodeless shape query to detect precise ledge geometry.

@export var body: CharacterBody2D

func check_ledge() -> bool:
    var space_state := get_world_2d().direct_space_state
    
    # Create an on-demand circle shape for detection.
    var shape := CircleShape2D.new()
    shape.radius = 4.0
    
    var query := PhysicsShapeQueryParameters2D.new()
    query.shape = shape
    query.transform = global_transform
    query.exclude = [body.get_rid()]
    
    var hits := space_state.intersect_shape(query)
    return not hits.is_empty()

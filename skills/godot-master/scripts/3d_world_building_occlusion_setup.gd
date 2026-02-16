# godot-master/scripts/3d_world_building_occlusion_setup.gd
extends Node3D

## Occlusion Culling Expert Pattern
## Blueprints for configuring OccluderInstance3D for draw-call reduction.

func setup_room_occlusion(room_node: Node3D) -> void:
    # 1. Create the OccluderInstance3D
    var occluder := OccluderInstance3D.new()
    occluder.name = "RoomOccluder"
    
    # 2. Assign or generate an OccluderPolygon3D
    # For simple rooms, a 'QuadOccluder3D' is most efficient.
    var poly := QuadOccluder3D.new()
    poly.size = Vector2(10, 5) # Match wall size
    occluder.occluder = poly
    
    room_node.add_child(occluder)

## EXPERT NOTE:
## Don't over-use complex occluders. Occlusion culling itself has a CPU cost.
## Best practice: Only occlusion-cull Large, Opaque objects (Walls, Ground, Big Rocks)
## that are guaranteed to hide many smaller objects behind them.

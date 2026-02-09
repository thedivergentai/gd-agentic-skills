# skills/navigation-pathfinding/code/dynamic_nav_manager.gd
extends NavigationRegion3D

## Dynamic Navigation Expert Pattern
## Manages runtime NavMesh re-baking for destructible environments.

@export var agent: NavigationAgent3D

func _ready() -> void:
    # 1. Initial Bake
    bake_navigation_mesh()

func update_nav_at_pos(pos: Vector3, size: Vector3) -> void:
    # 2. Localized Re-bake logic
    # Professional games DON'T re-bake the entire map.
    # Note: Godot 4 currently bakes regions, but expert usage 
    # involves Chunked NavigationRegions for massive maps.
    print("Re-baking Navigation at: ", pos)
    bake_navigation_mesh(false) # false = do not clear existing if using chunks

func _on_obstacle_destroyed() -> void:
    update_nav_at_pos(global_position, Vector3.ONE * 5.0)

## EXPERT NOTE:
## Use 'NavigationLink3D' nodes to connect isolated islands. 
## Set the 'link_type' to 'Jump' or 'Teleport' and detect the link 
## usage in the 'NavigationAgent3D' signal 'link_reached' to trigger 
## custom animations.
## NEVER update the NavMesh every frame. Use a 'Dirty Flag' system to 
## batch multiple updates into a single 'bake' call at the end of the frame.

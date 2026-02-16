# godot-master/scripts/server_architecture_rid_performance_server.gd
extends Node

## Server Architecture Expert Pattern
## Implements High-Performance RID Management (Scene Tree Bypass).

var _instance_rids: Array[RID] = []
var _mesh_rid: RID
var _material_rid: RID

func _enter_tree() -> void:
    # 1. Resource ID (RID) Mastery
    # Expert logic: Manually manage drawing without MeshInstance3D nodes.
    _mesh_rid = RenderingServer.mesh_create()
    # Assume a pre-loaded mesh resource for brevity
    # RenderingServer.mesh_add_surface_from_arrays(_mesh_rid, RenderingServer.PRIMITIVE_TRIANGLES, arrays)
    
    _material_rid = RenderingServer.material_create()

func spawn_instances(count: int, area_size: float) -> void:
    # 2. Direct RenderingServer Calls
    # This bypasses the overhead of 10,000 Node3D objects.
    for i in range(count):
        var instance = RenderingServer.instance_create()
        RenderingServer.instance_set_base(instance, _mesh_rid)
        RenderingServer.instance_set_scenario(instance, get_world_3d().scenario)
        
        var xform = Transform3D(Basis(), Vector3(
            randf_range(-area_size, area_size),
            0,
            randf_range(-area_size, area_size)
        ))
        RenderingServer.instance_set_transform(instance, xform)
        _instance_rids.append(instance)

func query_physics_direct(origin: Vector3, direction: Vector3) -> Dictionary:
    # 3. Direct PhysicsServer Queries
    # Professional pattern: Query the server directly instead of using RayCast3D node.
    var space_state = PhysicsServer3D.space_get_direct_state(get_world_3d().space)
    var query = PhysicsRayQueryParameters3D.create(origin, origin + direction * 100.0)
    
    return space_state.intersect_ray(query)

func _exit_tree() -> void:
    # CRITICAL: Manual cleanup of RIDs is mandatory to prevent memory leaks.
    for rid in _instance_rids:
        RenderingServer.free_rid(rid)
    RenderingServer.free_rid(_mesh_rid)
    RenderingServer.free_rid(_material_rid)

## EXPERT NOTE:
## Use 'WorkerThreadPool Batching': For 1 million+ calculations, split 
## the loop across cores: 'WorkerThreadPool.add_native_group_task(self, "_proc", count)'.
## For 'Headless Simulation', run Godot with '--headless' to disable 
## the OS window and Vulkan/OpenGL context for pure low-latency servers.
## NEVER instantiate Nodes for pure data or invisible calculation; 
## use RIDs or plain Objects to save 90% memory overhead.

# godot-master/scripts/open_world_world_streamer.gd
extends Node3D

## World Streamer (Expert Pattern)
## Manages loading/unloading of open world sectors/chunks based on distance.
## Uses background threads to prevent stutters.

class_name WorldStreamer

@export var tile_size: float = 256.0
@export var load_radius: int = 2
@export var player: Node3D

var active_tiles: Dictionary = {} # Vector2i -> Node (Loaded Scene)
var load_queue: Array[Vector2i] = []
var thread: Thread
var semaphore: Semaphore
var mutex: Mutex
var exit_thread: bool = false

func _ready() -> void:
    mutex = Mutex.new()
    semaphore = Semaphore.new()
    thread = Thread.new()
    thread.start(_loader_thread_func)

func _process(delta: float) -> void:
    if not player: return
    
    var center = _get_tile_coord(player.global_position)
    
    # Simple unloader
    var keep = []
    for x in range(-load_radius, load_radius + 1):
         for z in range(-load_radius, load_radius + 1):
             keep.append(center + Vector2i(x, z))
             
    var to_unload = []
    for k in active_tiles:
        if not k in keep:
            to_unload.append(k)
            
    for k in to_unload:
        active_tiles[k].queue_free()
        active_tiles.erase(k)
        
    # Queue loader
    for k in keep:
        if not active_tiles.has(k) and not k in load_queue:
            load_queue.append(k)
            semaphore.post()

func _loader_thread_func() -> void:
    while true:
        semaphore.wait()
        if exit_thread: break
        
        mutex.lock()
        if load_queue.is_empty():
            mutex.unlock()
            continue
            
        var coord = load_queue.pop_front()
        mutex.unlock()
        
        # Simulate loading / Actual loading
        # var scene = load("res://world/chunks/chunk_%d_%d.tscn" % [coord.x, coord.y])
        # CALL DEFERRED to add to tree
        call_deferred("_finish_load", coord, Node3D.new()) # Placeholder

func _finish_load(coord: Vector2i, node: Node) -> void:
    if active_tiles.has(coord): 
        node.queue_free() # Duplicate
        return
        
    add_child(node)
    node.global_position = Vector3(coord.x * tile_size, 0, coord.y * tile_size)
    active_tiles[coord] = node

func _get_tile_coord(pos: Vector3) -> Vector2i:
    return Vector2i(round(pos.x / tile_size), round(pos.z / tile_size))

func _exit_tree() -> void:
    exit_thread = true
    semaphore.post()
    thread.wait_to_finish()

## EXPERT USAGE:
## Configure tile_size to match terrain chunks. 
## Ensure scene files follow a naming convention or use a Resource directory.

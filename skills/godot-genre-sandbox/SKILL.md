---
name: godot-genre-sandbox
description: "Expert blueprint for sandbox games (Minecraft, Terraria, Garry's Mod) with physics-based interactions, cellular automata, emergent gameplay, and creative tools. Use when building open-world creation games with voxels, element systems, player-created structures, or procedural worlds. Keywords voxel, sandbox, cellular automata, MultiMesh, chunk management, emergent behavior, creative mode."
---

# Genre: Sandbox

Physical simulation, emergent play, and player creativity define this genre.

## Available Scripts

### [voxel_chunk_manager.gd](scripts/voxel_chunk_manager.gd)
Expert chunked rendering using `MultiMeshInstance3D` for thousands of voxels. Includes greedy meshing pattern and performance notes.

## Core Loop
1.  **Explore**: Player discovers world rules and materials
2.  **Experiment**: Player tests interactions (fire burns wood)
3.  **Build**: Player constructs structures or machines
4.  **Simulate**: Game runs physics/logic systems
5.  **Share**: Player saves/shares creation
6.  **Emergence**: Unintended complex behaviors from simple rules

## NEVER Do in Sandbox Games

- **NEVER simulate the entire world every frame** — Only update "dirty" chunks with recent changes. Sleeping chunks waste 90%+ of CPU. Use spatial hashing to track active regions.
- **NEVER use individual `RigidBody` nodes for voxels** — 1000+ physics bodies = instant crash. Use cellular automata for fluids/sand, static collision for solid blocks, and only dynamic bodies for player-placed objects.
- **NEVER save absolute transforms for every block** — A 256×256 world = 65,536 blocks. Use chunk-based RLE (Run-Length Encoding): `{type:AIR, count:50000}` compresses massive empty spaces.
- **NEVER update `MultiMesh` instance transforms every frame** — This forces GPU buffer updates. Batch changes, rebuild chunks when changed, not every tick.
- **NEVER hardcode element interactions** (`if wood + fire: burn()`) — Use property-based systems: `if temperature > ignition_point and flammable > 0`. This enables emergent combinations players discover.
- **NEVER use `Node` for every grid cell** — Nodes have 200+ bytes overhead. A million-block world would need 200MB+ just for node metadata. Use typed `Dictionary` or `PackedInt32Array` indexed by `position.x + position.y * width`.
- **NEVER raycast against all voxels for tool placement** — Use grid quantization: `floor(mouse_pos / block_size)` to directly calculate target cell. Raycasts are O(n) with voxel count.

## Architecture Patterns

### 1. Element System (Property-Based Emergence)
Model material properties, not behaviors. Interactions emerge from overlapping properties.

```gdscript
# element_data.gd
class_name ElementData extends Resource

enum Type { SOLID, LIQUID, GAS, POWDER }
@export var id: String = "air"
@export var type: Type = Type.GAS
@export var density: float = 0.0      # For liquid flow direction
@export var flammable: float = 0.0    # 0-1: Chance to ignite
@export var ignition_temp: float = 400.0
@export var conductivity: float = 0.0  # For electricity/heat
@export var hardness: float = 1.0     # Mining time multiplier

# EDGE CASE: What if two elements have same density but different types?
# SOLUTION: Use secondary sort (type enum priority: SOLID > LIQUID > POWDER > GAS)
func should_swap_with(other: ElementData) -> bool:
    if density == other.density:
        return type > other.type  # Enum comparison: SOLID(0) > GAS(3)
    return density > other.density
```

### 2. Cellular Automata Grid (Falling Sand Simulation)
Update order matters. Top-down prevents "teleporting" godot-particles.

```gdscript
# world_grid.gd
var grid: Dictionary = {}  # Vector2i -> ElementData
var dirty_cells: Array[Vector2i] = []

func _physics_process(_delta: float) -> void:
    # CRITICAL: Sort top-to-bottom to prevent double-moves
    dirty_cells.sort_custom(func(a, b): return a.y < b.y)
    
    for pos in dirty_cells:
        simulate_cell(pos)
    dirty_cells.clear()

func simulate_cell(pos: Vector2i) -> void:
    var cell = grid.get(pos)
    if not cell: return
    
    match cell.type:
        ElementData.Type.LIQUID, ElementData.Type.POWDER:
            # Try down, then down-left, then down-right
            var targets = [pos + Vector2i.DOWN, 
                           pos + Vector2i(- 1, 1), 
                           pos + Vector2i(1, 1)]
            for target in targets:
                var neighbor = grid.get(target)
                if neighbor and cell.should_swap_with(neighbor):
                    swap_cells(pos, target)
                    mark_dirty(target)
                    return
        
        ElementData.Type.GAS:
            # Gases rise (inverse of liquids)
            var targets = [pos + Vector2i.UP,
                           pos + Vector2i(-1, -1),
                           pos + Vector2i(1, -1)]
            # Same swap logic...

# EDGE CASE: What if multiple godot-particles want to move into same cell?
# SOLUTION: Only mark target dirty, don't double-swap. Next frame resolves conflicts.
```

### 3. Tool System (Strategy Pattern)
Decouple input from world modification.

```gdscript
# tool_base.gd
class_name Tool extends Resource
func use(world_pos: Vector2, world: WorldGrid) -> void: pass

# tool_brush.gd
extends Tool
@export var element: ElementData
@export var radius: int = 1

func use(world_pos: Vector2, world: WorldGrid) -> void:
    var grid_pos = Vector2i(floor(world_pos.x), floor(world_pos.y))
    
    # Circle brush pattern
    for x in range(-radius, radius + 1):
        for y in range(-radius, radius + 1):
            if x*x + y*y <= radius*radius:  # Circle boundary
                var target = grid_pos + Vector2i(x, y)
                world.set_cell(target, element)

# FALLBACK: If element placement fails (e.g., occupied by indestructible block)?
# Check world.can_place(target) before set_cell(), show visual feedback.
```

### 4. Chunk-Based Rendering (3D Voxels)
Only render visible faces. Use greedy meshing to merge adjacent blocks.

```gdscript
# See scripts/voxel_chunk_manager.gd for full implementation

# EXPERT DECISION TREE:
# - Small worlds (<100k blocks): Single MeshInstance with SurfaceTool
# - Medium worlds (100k-1M blocks): Chunked MultiMesh (see script)
# - Large worlds (>1M blocks): Chunked + greedy meshing + LOD
```

## Save System for Sandbox Worlds

```gdscript
# chunk_save_data.gd
class_name ChunkSaveData extends Resource

@export var chunk_coord: Vector2i
@export var rle_data: PackedInt32Array  # [type_id, count, type_id, count...]

# EXPERT TECHNIQUE: Run-Length Encoding
static func encode_chunk(grid: Dictionary, chunk_pos: Vector2i, chunk_size: int) -> ChunkSaveData:
    var data = ChunkSaveData.new()
    data.chunk_coord = chunk_pos
    
    var run_type: int = -1
    var run_count: int = 0
    
    for y in range(chunk_size):
        for x in range(chunk_size):
            var world_pos = chunk_pos * chunk_size + Vector2i(x, y)
            var cell = grid.get(world_pos)
            var type_id = cell.id if cell else 0  # 0 = air
            
            if type_id == run_type:
                run_count += 1
            else:
                if run_count > 0:
                    data.rle_data.append(run_type)
                    data.rle_data.append(run_count)
                run_type = type_id
                run_count = 1
    
    # Flush final run
    if run_count > 0:
        data.rle_data.append(run_type)
        data.rle_data.append(run_count)
    
    return data

# COMPRESSION RESULT: Empty chunk (16×16 = 256 blocks of air)
# Without RLE: 256 integers = 1024 bytes
# With RLE: [0, 256] = 8 bytes (128x compression!)
```

## Physics Joints for Player Creations

```gdscript
# joint_tool.gd
func create_hinge(body_a: RigidBody2D, body_b: RigidBody2D, anchor: Vector2) -> void:
    var joint = PinJoint2D.new()
    joint.global_position = anchor
    joint.node_a = body_a.get_path()
    joint.node_b = body_b.get_path()
    joint.softness = 0.5  # Allows slight flex
    add_child(joint)
    
    # EDGE CASE: What if bodies are deleted while joint exists?
    # Joint will auto-break in Godot 4.x, but orphaned Node leaks memory.
# SOLUTION:
    body_a.tree_exiting.connect(func(): joint.queue_free())
    body_b.tree_exiting.connect(func(): joint.queue_free())

# FALLBACK: Player attaches joint to static geometry?
# Check `body.freeze == false` before creating joint.
```

## Godot-Specific Expert Notes

- **`MultiMeshInstance3D.multimesh.instance_count`**: MUST be set before buffer allocation. Cannot dynamically grow — requires recreation.
- **`RigidBody2D.sleeping`**: Bodies auto-sleep after 2 seconds of no movement. Use `apply_central_impulse(Vector2.ZERO)` to force wake without adding force.
- **`GridMap` vs `MultiMesh`**: GridMap uses MeshLibrary (great for variety), MultiMesh uses single mesh (great for speed). Combine: GridMap for structures, MultiMesh for terrain.
- **Continuous CD**: `continuous_cd` requires convex collision shapes. Use `CapsuleShape2D` for projectiles, NOT `RectangleShape2D`.


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)

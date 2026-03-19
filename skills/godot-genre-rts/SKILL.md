---
name: godot-genre-rts
description: "Expert blueprint for real-time strategy games including unit selection (drag box, shift-add), command systems (move, attack, gather), pathfinding (NavigationAgent2D with RVO avoidance), fog of war (SubViewport mask shader), resource economy (gather/build loop), and AI opponents (behavior trees, utility AI). Use for base-building RTS or tactical combat games. Trigger keywords: RTS, unit_selection, command_system, fog_of_war, pathfinding_RVO, resource_economy, command_queue."
---

# Genre: Real-Time Strategy (RTS)

Expert blueprint for RTS games balancing strategy, micromanagement, and performance.

## NEVER Do (Expert Anti-Patterns)

### Unit Logic & Pathfinding
- NEVER allow pathfinding "Jitter" when moving group units; strictly **stagger path queries** and enable **RVO Avoidance** only when units are in motion to save CPU cycles.
- NEVER update RVO avoidance every frame for all units; strictly use **Avoidance Threading** (Project Settings) and replace static units with `NavigationObstacle`.
- NEVER let units get stuck in infinite path loops; strictly implement a **timeout and IDLE state** if a destination is unreachable.
- NEVER use `_process()` on hundreds of individual units; strictly use a central **UnitManager** or `_physics_process` only when required.
- NEVER calculate unit visibility manually for Fog of War; strictly use a **Shader-based mask** (SubViewport + ColorRect) for GPU efficiency.
- NEVER process unit AI or pathfinding synchronously for mass groups; strictly offload to **`WorkerThreadPool`** and stagger path updates.
- NEVER use high-poly visual meshes as NavMesh source geometry; strictly use simplified **Collision Shapes** for baking.

### Interaction & Commands
- NEVER forget **Command Queuing** (Shift-Click); strictly store an `Array[Command]` and implement a "Force Move/Attack" bypass.
- NEVER create excessive micromanagement; strictly automate low-level tasks like **auto-aggro range** and auto-return for resource gathering.
- NEVER use exact floating-point equality (==) for grid or timers; strictly use `is_equal_approx()` for deterministic triggers.
- NEVER rely on the visual SceneTree for selection data; strictly maintain a **Typed Selection Set** of `RefCounted` or `Resource` objects for deterministic serialization and netcode.
- NEVER forget **Command Queuing**; strictly implement a **Command Pattern** using serializable `Dictionary` or `JSON` states for save-game and multiplayer playback.
- NEVER forget to **duplicate_deep()** globally shared Resources; otherwise, modifying one unit's data (e.g., stats) affects all.

### Performance & Simulation
- NEVER render thousands of units using separate `MeshInstance3D` nodes; strictly use **`MultiMeshInstance`** with **`INSTANCE_CUSTOM`** data to drive unique GPU-side state animations (walking/attacking/color).
- NEVER calculate transforms for mass units on the main thread; strictly use **`WorkerThreadPool`** to push buffers to `RenderingServer.multimesh_set_buffer()`.
- NEVER update every unit's navigation path in the same frame; strictly use random timers to **stagger updates**.
- NEVER use standard Strings for high-frequency AI state identifiers; strictly use **StringName** (&"harvesting") for pointer-speed comparisons.
- NEVER allow simulation coordinates to exceed 8192 units without float-precision management; strictly use world-origin shifts.
- NEVER use `CSGShape3D` for building placement ghosts; strictly use optimized static `ArrayMesh` geometry.

---

## 🛠 Expert Components (scripts/)

### Original Expert Patterns
- [selection_manager_marquee_2d.gd](scripts/selection_manager_marquee_2d.gd) - Professional-grade unit selection system with drag-box, unit filtering, and shift-add support.

### Modular Components
- [rts_army_manager.gd](scripts/rts_army_manager.gd) - Multithreaded AI update system for managing mass units on background cores.
- [selection_manager_raycast_3d.gd](scripts/selection_manager_raycast_3d.gd) - Optimized 3D selection using direct PhysicsServer raycasting.
- [rts_path_query_pool.gd](scripts/rts_path_query_pool.gd) - Pooled Navigation query system to prevent memory allocations.
- [navigation_mask_helper.gd](scripts/navigation_mask_helper.gd) - Bitmask utilities for dynamic navigation layers and avoidance.
- [rts_targeting_logic.gd](scripts/rts_targeting_logic.gd) - Distance-squared performance optimization for mass enemy filtering.
- [rts_group_commander.gd](scripts/rts_group_commander.gd) - SceneTree group broadcasting pattern for decoupled mass units.
- [rts_unit_stat_duplicator.gd](scripts/rts_unit_stat_duplicator.gd) - Pattern for deep duplicating unit data for isolation.
- [rts_unit.gd](scripts/rts_unit.gd) - Comprehensive unit controller with state management and navigation integration.
- [building_grid_astar.gd](scripts/building_grid_astar.gd) - High-speed grid-based pathfinding for building placement.
- [fog_of_war_tile_mask.gd](scripts/fog_of_war_tile_mask.gd) - Efficient Fog of War clearing using the TileMapLayer API and Vector2i.
- [rendering_ghost_spawner.gd](scripts/rendering_ghost_spawner.gd) - Optimized placement ghosts using RenderingServer RIDs.

---

## Core Loop
1.  **Gather**: Units collect resources (Gold, Wood, etc.).
2.  **Build**: Construct base buildings to unlock tech/units.
3.  **Train**: Produce an army of diverse units.
4.  **Command**: Micromanage units in real-time battles.
5.  **Expand**: Secure map control and resources.

## Skill Chain

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Controls | `godot-input-handling`, `camera-rts` | Selection box, camera panning/zoom |
| 2. Units | `navigation-server`, `state-machines` | Pathfinding, avoidance, states (Idle/Move/Attack) |
| 3. Systems | `fog-of-war`, `building-system` | Map visibility, grid placement |
| 4. AI | `behavior-trees`, `utility-ai` | Enemy commander logic |
| 5. Polish | `ui-minimap`, `godot-particles` | Strategic overview, battle feedback |

## Architecture Overview

### 1. Selection Manager (Singleton or Commander Node)
Handles mouse input for selecting units.

```gdscript
# selection_manager.gd
extends Node2D

var selected_units: Array[Unit] = []
var drag_start: Vector2
var is_dragging: bool = false
@onready var selection_box: Panel = $SelectionBox

func _unhandled_input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            start_selection(event.position)
        else:
            end_selection(event.position)
    elif event is InputEventMouseMotion and is_dragging:
        update_selection_box(event.position)

func end_selection(end_pos: Vector2):
    is_dragging = false
    selection_box.visible = false
    var rect = Rect2(drag_start, end_pos - drag_start).abs()
    
    if Input.is_key_pressed(KEY_SHIFT):
        # Add to selection
        pass
    else:
        deselect_all()
        
    # Query physics server for units in rect
    var query = PhysicsShapeQueryParameters2D.new()
    var shape = RectangleShape2D.new()
    shape.size = rect.size
    query.shape = shape
    query.transform = Transform2D(0, rect.get_center())
    # ... execute query and add units to selected_units
    
    for unit in selected_units:
        unit.set_selected(true)

func issue_command(target_position: Vector2):
    for unit in selected_units:
        unit.move_to(target_position)
```

### 2. Unit Controller (State Machine)
Units need robust state management to handle commands and auto-attacks.

```gdscript
# unit.gd
extends CharacterBody2D
class_name Unit

enum State { IDLE, MOVE, ATTACK, HOLD }
var state: State = State.IDLE
var command_queue: Array[Command] = []

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func move_to(target: Vector2):
    nav_agent.target_position = target
    state = State.MOVE

func _physics_process(delta):
    if state == State.MOVE:
        if nav_agent.is_navigation_finished():
            state = State.IDLE
            return
            
        var next_pos = nav_agent.get_next_path_position()
        var direction = global_position.direction_to(next_pos)
        velocity = direction * speed
        move_and_slide()

### 3. Group Movement & Flocking
Instead of moving all units directly to a single point (clumping), use **Relative Offsets**:
- Calculate the **Center of Mass** for the selected group.
- On click, calculate each unit's **Relative Offset** from the center.
- Issue `target_position + unit_offset` to each unit to maintain formation.
```

### 3. Fog of War
A system to hide unvisited areas. Usually implemented with a texture and a shader.

*   **Grid Approach**: 2D array of "visibility" values.
*   **Viewport Texture**: A `SubViewport` drawing white circles for units on a black background. This texture is then used as a mask in a shader on a full-screen `ColorRect` overlay.

```gdshader
shader_type canvas_item;
uniform sampler2D visibility_texture; 
uniform vec4 fog_color : source_color;

void fragment() {
    float visibility = texture(visibility_texture, UV).r;
    COLOR = mix(fog_color, vec4(0,0,0,0), visibility);
}
```

## Key Mechanics Implementation

### Command Queue
Allow players to chain commands (Shift-Click).
*   **Implementation**: Store commands in an `Array`. When one finishes, pop the next.
*   **Visuals**: Draw lines showing the queued path.

### Resource Gathering
*   **Nodes**: `ResourceNode` (Tree/GoldMine) and `DropoffPoint` (TownCenter).
*   **Logic**:
    1.  Move to Resource.
    2.  Work (Timer).
    3.  Move to Dropoff.
    4.  Deposit (Global Economy update).
    5.  Repeat.

## Common Pitfalls

1.  **Pathfinding Jitter**: Units pushing each other endlessly. **Fix**: Use RVO (Reciprocal Velocity Obstacles) built into Godot's `NavigationAgent2D` (properties `avoidance_enabled`, `radius`).
2.  **Too Much Micro**: Automate mundane tasks (auto-attack nearby, auto-gather behavior).
3.  **Performance**: Too many nodes. **Fix**: Use `MultiMeshInstance2D` for rendering thousands of units if needed, and run logic on a `Server` node rather than individual scripts for mass units.

## Godot-Specific Tips

*   **Avoidance**: `NavigationAgent2D` has built-in RVO avoidance. Make sure to call `set_velocity()` and use the `velocity_computed` signal for the actual movement!
*   **Server Architecture**: For 100+ units, don't use `_process` on every unit. Have a central `UnitManager` iterate through active units to save function call overhead.
*   **Groups**: Use Groups heavily (`Units`, `Buildings`, `Resources`) for easy selection filters.


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)

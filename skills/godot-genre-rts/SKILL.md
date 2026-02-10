---
name: godot-genre-rts
description: "Expert blueprint for real-time strategy games including unit selection (drag box, shift-add), command systems (move, attack, gather), pathfinding (NavigationAgent2D with RVO avoidance), fog of war (SubViewport mask shader), resource economy (gather/build loop), and AI opponents (behavior trees, utility AI). Use for base-building RTS or tactical combat games. Trigger keywords: RTS, unit_selection, command_system, fog_of_war, pathfinding_RVO, resource_economy, command_queue."
---

# Genre: Real-Time Strategy (RTS)

Expert blueprint for RTS games balancing strategy, micromanagement, and performance.

## NEVER Do

- **NEVER pathfinding jitter** — Units pushing each other endlessly. Enable RVO avoidance (NavigationAgent2D.avoidance_enabled with radius).
- **NEVER excessive micromanagement** — Automate mundane tasks (auto-attack nearby enemies, auto-resume gathering after drop-off).
- **NEVER _process on every unit** — For 100+ units, use central UnitManager iterator. Saves massive function call overhead.
- **NEVER skip command queuing** — Players expect Shift+Click to chain commands. Store Array[Command] and process sequentially.
- **NEVER forget fog of war** — Unvisited areas should be hidden. Use SubViewport + shader mask for performance.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [rts_selection_manager.gd](scripts/rts_selection_manager.gd)
Mouse-box unit selection with shift-add. Camera projection for 3D units, command issuing with queue support (shift+right click).

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

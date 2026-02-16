> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Real-Time Strategy (RTS)**. Accessed via Godot Master.

# Genre: Real-Time Strategy (RTS)

Expert blueprint for building RTS games. Covers high-volume unit selection (Marquee/Drag-box), pathfinding with RVO avoidance, and strategic systems like Fog of War and resource economies.

## Available Scripts

### [rts_selection_manager.gd](../scripts/rts_rts_selection_manager.gd)
A professional-grade unit selection system. Handles screen-space drag-box (Marquee) selection, unit filtering (groups), shift-add selection, and command issuance for group movement.


## NEVER Do

- **NEVER allow pathfinding "Jitter"** — When 50 units move to the same point, they will endlessly push each other without arriving. **Enable RVO Avoidance** in your `NavigationAgent2D` or `NavigationAgent3D` settings (`avoidance_enabled = true`).
- **NEVER use `_process()` on every single unit** — If you have 500 units, the cost of 500 script calls every frame will tank performance. Use a central **UnitManager** that iterates through an array of active units to process their logic.
- **NEVER forget Command Queuing** — RTS players expect to chain actions (e.g., "Build this, then gather that"). Store an `Array[Command]` on your units and process the next entry only when the current one is finished.
- **NEVER let units get stuck in Infinite Loops** — When a unit is blocked (e.g., path is unreachable), it must time out and return to an `IDLE` state rather than constantly recalculating the path every frame.
- **NEVER ignore Fog of War performance** — Calculating visibility for 100 units by hand every frame is too slow. Use a **Shader-based mask** (SubViewport + ColorRect) to hide/reveal the map efficiently on the GPU.
- **NEVER create excessive micromanagement** — Automate low-level tasks. Units should automatically attack nearby enemies (within an "Aggro" range) or automatically return to gathering resources after dropping them off.

---

## Unit Selection: The Marquee Pattern
1. **Start Drag**: Store `get_global_mouse_position()` on `Input.is_action_just_pressed`.
2. **Updating**: Draw a `Panel` or `ColorRect` between the start and the current mouse position.
3. **End Drag**: Create a `Rect2` from the two points and query the physics engine:
   `var results = get_world_2d().direct_space_state.intersect_shape(query)`

## Group Movement and Flocking
Instead of moving all units directly to the mouse click, use **Offsets**:
- Calculate the center of the selected group.
- Maintain the units' relative positions to that center when issuing the `TargetPosition`.
- This prevents units from clumping into a single pixel.

## Fog of War System
1. **Black Layer**: A `ColorRect` covering the whole map with a custom shader.
2. **Mask Texture**: A `SubViewport` that draws white circles (visibility) for every player unit.
3. **Shader**: The mask texture's "Red" channel determines the alpha of the Black Layer.

## Resource Gathering Loop
Implementation steps:
- **State: MOVING_TO_SOURCE**: Navigates to the Gold Mine/Tree.
- **State: GATHERING**: Triggers a timer/animation.
- **State: MOVING_TO_DROPOFF**: Navigates to the Town Center.
- **State: DEPOSITING**: Updates the global `EconomySystem` resource.

## Performance for Mass Units
- Use **Groups** (`add_to_group("unit")`) for lightning-fast selection filtering.
- Use `move_and_slide()` efficiently by disabling it when a unit is `IDLE`.
- Consider `MultiMeshInstance2D` for rendering thousands of simple units (e.g., swarms).

## Reference
- [Godot Docs: NavigationAgent Avoidance](https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationagents.html)
- [Valve Wiki: RTS Selection Logic](https://developer.valvesoftware.com/wiki/RTS_Controls)

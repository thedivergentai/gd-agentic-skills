> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Server Architecture (Low-Level)**. Accessed via Godot Master.

# Server Architecture (RID-Based)

Expert blueprint for high-performance systems that bypass the Scene Tree and utilize Godot's low-level servers (`RenderingServer`, `PhysicsServer2D/3D`, `NavigationServer`) via Resource IDs (RIDs).

## Available Scripts

### [headless_manager.gd](../scripts/server_architecture_headless_manager.gd)
Manages the lifecycle of a dedicated Linux/Windows server. Handles argument parsing (e.g., `--port`, `--max-players`), headless mode optimizations, and clean shutdown procedures.

### [rid_performance_server.gd](../scripts/server_architecture_rid_performance_server.gd)
Advanced wrapper for direct RID management. Provides boilerplate for batch operations on rendering and physics servers, significantly reducing CPU overhead for massive object counts.


## NEVER Do

- **NEVER forget to manually free RIDs** — Unlike Nodes, RIDs are not garbage collected or managed by the Scene Tree. If you call `RenderingServer.canvas_item_create()`, you MUST call `RenderingServer.free_rid(rid)` to avoid permanent memory leaks.
- **NEVER combine Server APIs and Nodes for the same object** — Using both an RID-based body and a `CharacterBody3D` for a single entity leads to logic conflicts and doubles your physics simulation cost.
- **NEVER use Servers for high-level prototyping** — Low-level code has no visual inspector or node hierarchy. Only move logic to Servers after a Feature is proven and identified as a performance bottleneck.
- **NEVER skip validity checks on stored RIDs** — Passing an invalid or freed RID to the engine will cause an immediate crash. Always verify with `rid.is_valid()` before use.
- **NEVER use `RenderingServer` to build standard UI** — UI elements require complex layering and input propagation. Always use `Control` nodes for interfaces; only use `RenderingServer` for game-world visuals.
- **NEVER forget to set shape transforms** — When creating a body in `PhysicsServer`, a newly added shape defaults to (0,0). You must explicitly call `body_set_shape_transform` to position the collision volume correctly.

---

## When to Use Servers
Standard Nodes are highly optimized and should be used for 90% of game objects. Low-level Servers are reserved for:
- Thousands of projectiles or foliage instances.
- Voxel or marching cubes terrain engines.
- Large-scale procedural generation where Node overhead is too high.

## Direct Rendering (RenderingServer)
Instead of a `Sprite2D` node:
1. Create a `canvas_item` RID.
2. Parent it to the viewport or a node's canvas.
3. Call `canvas_item_add_texture_rect` to draw.
4. Update properties (position, modulate) directly via the server API.

## Direct Physics (PhysicsServer)
Instead of a `RigidBody3D` node:
1. Create a `body` RID with circles/box shapes.
2. Set the body state (position, velocity).
3. The server simulates physics autonomously; you poll the RIDs for transform data only when needed for rendering.

## Headless Server Mode
When running as a dedicated server:
- Use `--headless` flag.
- Disable sound (`--no-window`).
- Use `headless_manager.gd` to parse connectivity data and bridge with the `MultiplayerAPI`.

## Reference
- [Godot Docs: Optimization with Servers](https://docs.godotengine.org/en/stable/tutorials/performance/using_servers.html)
- [Godot Docs: RID Class](https://docs.godotengine.org/en/stable/classes/class_rid.html)

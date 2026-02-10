---
name: godot-server-architecture
description: "Expert blueprint for low-level server access (RenderingServer, PhysicsServer2D/3D, NavigationServer) using RIDs for maximum performance. Bypasses scene tree overhead for procedural generation, particle systems, and voxel engines. Use when nodes are too slow OR managing thousands of objects. Keywords RenderingServer, PhysicsServer, NavigationServer, RID, canvas_item, body_create, low-level, performance."
---

# Server Architecture

RID-based server API, direct rendering/physics access, and object pooling define maximum-performance patterns.

## Available Scripts

### [headless_manager.gd](scripts/headless_manager.gd)
Manager for dedicated server lifecycle, argument parsing, and headless mode optimization.

### [rid_performance_server.gd](scripts/rid_performance_server.gd)
Expert server wrapper with RID lifecycle management and batch operations.

## NEVER Do in Server Architecture

- **NEVER forget to free RIDs** — `RenderingServer.canvas_item_create()` without free? Memory leak (GC doesn't track RIDs). MUST call `canvas_item_free(rid)` when done.
- **NEVER mix server API with nodes for same object** — Creating RID body AND CharacterBody2D for same entity? Conflicts + double simulation cost. Pick ONE approach.
- **NEVER use servers for prototyping** — Debugging server code is painful (no Inspector, print_tree, or visual tools). Use Nodes first, optimize to servers later.
- **NEVER skip RID validation** — Calling `body_set_state(invalid_rid, ...)` = crash. Use `RID.is_valid(rid)` OR track RIDs in Array/Dictionary.
- **NEVER use servers without profiling first** — Premature optimization. Nodes handle 10k+ objects fine in Godot 4. Profile FIRST, then replace bottlenecks with servers.
- **NEVER forget to set shape transform** — `PhysicsServer2D.body_add_shape(body, shape)` without transform? Shape at (0,0) offset. Set transform via `body_set_shape_transform()`.
- **NEVER use RenderingServer for UI** — UI elements via canvas_item_create()? No automatic layering, input, or theming. Use Control nodes for UI.

---

Direct access to rendering without nodes.

```gdscript
# Create canvas item (2D sprite equivalent)
var canvas_item := RenderingServer.canvas_item_create()
RenderingServer.canvas_item_set_parent(canvas_item, get_canvas_item())

# Draw texture
var texture_rid := load("res://icon.png").get_rid()
RenderingServer.canvas_item_add_texture_rect(
    canvas_item,
    Rect2(0, 0, 64, 64),
    texture_rid
)
```

## PhysicsServer2D

Create physics bodies without nodes.

```gdscript
# Create body
var body_rid := PhysicsServer2D.body_create()
PhysicsServer2D.body_set_mode(body_rid, PhysicsServer2D.BODY_MODE_RIGID)

# Create shape
var shape_rid := PhysicsServer2D.circle_shape_create()
PhysicsServer2D.shape_set_data(shape_rid, 16.0)  # radius

# Assign shape to body
PhysicsServer2D.body_add_shape(body_rid, shape_rid)
```

## When to Use Servers

**Use servers for:**
- Procedural generation (thousands of objects)
- Particle systems
- Voxel engines
- Custom rendering

**Use nodes for:**
- Regular game objects
- UI
- Prototyping

## Reference
- [Godot Docs: Using Servers](https://docs.godotengine.org/en/stable/tutorials/performance/using_servers.html)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)

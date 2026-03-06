---
name: godot-master
description: "Consolidated expert library for professional Godot 4.x game and application development. Orchestrates 94 specialized blueprints through architectural workflows, anti-pattern catalogs, performance budgets, and Server API patterns. Use when: (1) starting a new Godot project, (2) designing game or app architecture, (3) building entity/component systems, (4) debugging performance or physics issues, (5) choosing between 2D/3D approaches, (6) implementing multiplayer, (7) optimizing draw calls or script time, (8) porting between platforms. Primary entry point for ALL Godot development tasks."
---

# Godot Master: Lead Architect Knowledge Hub

Every section earns its tokens by focusing on **Knowledge Delta** — the gap between what Claude already knows and what a senior Godot engineer knows from shipping real products.

---

## 🧠 Part 1: Expert Thinking Frameworks

### "Who Owns What?" — The Architecture Sanity Check
Before writing any system, answer these three questions for EVERY piece of state:
- **Who owns the data?** (The `StatsComponent` owns health, NOT the `CombatSystem`)
- **Who is allowed to change it?** (Only the owner via a public method like `apply_damage()`)
- **Who needs to know it changed?** (Anyone listening to the `health_changed` signal)

If you can't answer all three for every state variable, your architecture has a coupling problem. This is not OOP encapsulation — this is Godot-specific because the **signal system IS the enforcement mechanism**, not access modifiers.

### The Godot "Layer Cake"
Organize every feature into four layers. Signals travel UP, never down:
```
┌──────────────────────────────┐
│  PRESENTATION (UI / VFX)     │  ← Listens to signals, never owns data
├──────────────────────────────┤
│  LOGIC (State Machines)      │  ← Orchestrates transitions, queries data
├──────────────────────────────┤
│  DATA (Resources / .tres)    │  ← Single source of truth, serializable
├──────────────────────────────┤
│  INFRASTRUCTURE (Autoloads)  │  ← Signal Bus, SaveManager, AudioBus
└──────────────────────────────┘
```
**Critical rule**: Presentation MUST NOT modify Data directly. Infrastructure speaks exclusively through signals. If a `Label` node is calling `player.health -= 1`, the architecture is broken.

### The Signal Bus Tiered Architecture
- **Global Bus (Autoload)**: ONLY for lifecycle events (`match_started`, `player_died`, `settings_changed`). Debugging sprawl is the cost — limit events to < 15.
- **Scoped Feature Bus**: Each feature folder has its own bus (e.g., `CombatBus` only for combat nodes). This is the compromise that scales.
- **Direct Signals**: Parent-child communication WITHIN a single scene. Never across scene boundaries.

---

## 🧭 Part 2: Architectural Decision Frameworks

### The Master Decision Matrix

| Scenario | Strategy | **MANDATORY** Skill Chain | Trade-off |
| :--- | :--- | :--- | :--- |
| **Rapid Prototype** | Event-Driven Mono | **READ**: [Foundations](references/project_foundations.md) → [Autoloads](references/autoload_architecture.md). **Do NOT load** genre or platform refs. | Fast start, spaghetti risk |
| **Complex RPG** | Component-Driven | **READ**: [Composition](references/composition.md) → [States](references/state_machine_advanced.md) → [RPG Stats](references/rpg_stats.md). **Do NOT load** multiplayer or platform refs. | Heavy setup, infinite scaling |
| **Massive Open World** | Resource-Streaming | **READ**: [Open World](references/open_world.md) → [Save/Load](references/save_load_systems.md). Also load [Performance](references/performance_optimization.md). | Complex I/O, float precision jitter past 10K units |
| **Server-Auth Multi** | Deterministic | **READ**: [Server Arch](references/server_architecture.md) → [Multiplayer](references/multiplayer_networking.md). **Do NOT load** single-player genre refs. | High latency, anti-cheat secure |
| **Mobile/Web Port** | Adaptive-Responsive | **READ**: [UI Containers](references/ui_containers.md) → [Adapt Desk→Mobile](references/adapt_desktop_mobile.md) → [Platform Mobile](references/platform_mobile.md). | UI complexity, broad reach |
| **Application / Tool** | App-Composition | **READ**: [App Composition](references/composition_apps.md) → [Theming](references/ui_theming.md). **Do NOT load** game-specific refs. | Different paradigm than games |
| **Romance / Dating Sim** | Affection Economy | **READ**: [Romance](references/romance.md) → [Dialogue](references/dialogue_system.md) → [UI Rich Text](references/ui_rich_text.md). | High UI/Narrative density |
| **Secrets / Easter Eggs** | Intentional Obfuscation | **READ**: [Secrets](references/mechanic-secrets.md) → [Persistence](references/save_load_systems.md). | Community engagement, debug risk |
| **Collection Quest** | Scavenger Logic | **READ**: [Collections](references/game-loop-collection.md) → [Marker3D Placement](references/3d_world_building.md). | Player retention, exploration drive |
| **Seasonal Event** | Runtime Injection | **READ**: [Easter Theming](references/theme-easter.md) → [Material Swapping](references/3d_materials.md). | Fast branding, no asset pollution |
| **Souls-like Mortality** | Risk-Reward Revival | **READ**: [Revival/Corpse Run](references/mechanic-revival.md) → [Physics 3D](references/physics_3d.md). | High tension, player frustration risk |
| **Wave-based Action** | Combat Pacing Loop | **READ**: [Waves](references/game-loop-waves.md) → [Combat](references/combat_system.md). | Escalating tension, encounter design |
| **Survival Economy** | Harvesting Loop | **READ**: [Harvesting](references/game-loop-harvest.md) → [Inventory](references/inventory_system.md). | Resource scarcity, loop persistence |
| **Racing / Speedrun** | Validation Loop | **READ**: [Time Trials](references/game-loop-time-trial.md) → [Input Buffer](references/input_handling.md). | High precision, ghost record drive |

### The "When NOT to Use a Node" Decision
One of the most impactful expert-only decisions. The Godot docs explicitly say "avoid using nodes for everything":

| Type | When to Use | Cost | Expert Use Case |
| :--- | :--- | :--- | :--- |
| **`Object`** | Custom data structures, manual memory management | Lightest. Must call `.free()` manually. | Custom spatial hash maps, ECS-like data stores |
| **`RefCounted`** | Transient data packets, logic objects that auto-delete | Auto-deleted when no refs remain. | `DamageRequest`, `PathQuery`, `AbilityEffect` — logic packets that don't need the scene tree |
| **`Resource`** | Serializable data with Inspector support | Slightly heavier than RefCounted. Handles `.tres` I/O. | `ItemData`, `EnemyStats`, `DialogueLine` — any data a designer should edit in Inspector |
| **`Node`** | Needs `_process`/`_physics_process`, needs to live in the scene tree | Heaviest — SceneTree overhead per node. | Only for entities that need per-frame updates or spatial transforms |

**The expert pattern**: Use `RefCounted` subclasses for all logic packets and data containers. Reserve `Node` for things that must exist in the spatial tree. This halves scene tree overhead for complex systems.

---

## 🔧 Part 3: Core Workflows

### Workflow 1: Professional Scaffolding
*From empty project to production-ready container.*

**MANDATORY — READ ENTIRE FILE**: [Foundations](references/project_foundations.md)
1. Organize by **Feature** (`/features/player/`, `/features/combat/`), not by class type. A `player/` folder contains the scene, script, resources, and tests for the player.
2. **READ**: [Signal Architecture](references/signal_architecture.md) — Create `GlobalSignalBus` autoload with < 15 events.
3. **READ**: [GDScript Mastery](references/gdscript_mastery.md) — Enable `untyped_declaration` warning in Project Settings → GDScript → Debugging.
4. Apply **[Project Templates](references/project_templates.md)** for base `.gitignore`, export presets, and input map.
5. Use **[MCP Scene Builder](references/mcp_scene_builder.md)** if available to generate scene hierarchies programmatically.
**Do NOT load** combat, multiplayer, genre, or platform references during scaffolding.

### Workflow 2: Entity Orchestration
*Building modular, testable characters.*

**MANDATORY Chain — READ ALL**: [Composition](references/composition.md) → [State Machine](references/state_machine_advanced.md) → [CharacterBody2D](references/characterbody_2d.md) or [Physics 3D](references/physics_3d.md) → [Animation Tree](references/animation_tree_mastery.md)
**Do NOT load** UI, Audio, or Save/Load references for entity work.

- The State Machine queries an `InputComponent`, never handles input directly. This allows AI/Player swap with zero refactoring.
- The State Machine ONLY handles transitions. Logic belongs in Components. `MoveState` tells `MoveComponent` to act, not the other way around.
- Every entity MUST pass the **F6 test**: pressing "Run Current Scene" (F6) must work without crashing. If it crashes, your entity has scene-external dependencies.

### Workflow 3: Data-Driven Systems
*Connecting Combat, Inventory, Stats through Resources.*

**MANDATORY Chain — READ ALL**: [Resource Patterns](references/resource_data_patterns.md) → [RPG Stats](references/rpg_stats.md) → [Combat](references/combat_system.md) → [Inventory](references/inventory_system.md)

- Create ONE `ItemData.gd` extending `Resource`. Instantiate it as 100 `.tres` files instead of 100 scripts.
- The HUD NEVER references the Player directly. It listens for `player_health_changed` on the Signal Bus.
- Enable "Local to Scene" on ALL `@export Resource` variables, or call `resource.duplicate()` in `_ready()`. Failure to do this is Bug #1 in Part 8.

### Workflow 4: Persistence Pipeline
**MANDATORY**: [Autoload Architecture](references/autoload_architecture.md) → [Save/Load](references/save_load_systems.md) → [Scene Management](references/scene_management.md)

- Use dictionary-mapped serialization. Old save files MUST not corrupt when new fields are added — use `.get("key", default_value)`.
- For procedural worlds: save the **Seed** plus a **Delta-List** of modifications, not the entire map. A 100MB world becomes a 50KB save.

### Workflow 5: Performance Optimization
**MANDATORY**: [Debugging/Profiling](references/debugging_profiling.md) → [Performance Optimization](references/performance_optimization.md)

**Diagnosis-first approach** (NEVER optimize blindly):
1. **High Script Time** → Profile with built-in Profiler. Check if `_process` is being called on hundreds of nodes. Move to single-manager pattern or Server APIs (see Part 6).
2. **High Draw Calls** → Use `MultiMeshInstance` for repetitive geometry. Batch materials with ORM textures.
3. **Physics Stutter** → Simplify collisions to primitive shapes. Load [2D Physics](references/2d_physics.md) or [3D Physics](references/physics_3d.md). Check if `_process` is used instead of `_physics_process` for movement.
4. **VRAM Overuse** → Switch textures to VRAM Compression (BPTC/S3TC for desktop, ETC2 for mobile). Never ship raw PNG.
5. **Intermittent Frame Spikes** → Usually GC pass, synchronous `load()`, or NavigationServer recalculation. Use `ResourceLoader.load_threaded_request()`.

### Workflow 6: Cross-Platform Adaptation
**MANDATORY**: [Input Handling](references/input_handling.md) → [Adapt Desktop→Mobile](references/adapt_desktop_mobile.md) → [Platform Mobile](references/platform_mobile.md)
**Also read**: [Platform Desktop](references/platform_desktop.md), [Platform Web](references/platform_web.md), [Platform Console](references/platform_console.md), [Platform VR](references/platform_vr.md) as needed.

- Use an `InputManager` autoload that translates all input types into normalized actions. NEVER read `Input.is_key_pressed()` directly — it blocks controller and touch support.
- Mobile touch targets: minimum 44px physical size. Use `MarginContainer` with Safe Area logic for notch/cutout devices.
- Web exports: Godot's `AudioServer` requires user interaction before first play (browser policy). Handle this with a "Click to Start" screen.

### Workflow 7: Procedural Generation
**MANDATORY**: [Procedural Gen](references/procedural_generation.md) → [Tilemap Mastery](references/tilemap_mastery.md) or [3D World Building](references/3d_world_building.md) → [Navigation](references/navigation_pathfinding.md)

- ALWAYS use `FastNoiseLite` resource with a fixed `seed` for deterministic generation.
- Never bake NavMesh on the main thread. Use `NavigationServer3D.parse_source_geometry_data()` + `NavigationServer3D.bake_from_source_geometry_data_async()`.
- For infinite worlds: chunk loading MUST happen on a background thread using `WorkerThreadPool`. Build the scene chunk off-tree, then `add_child.call_deferred()` on the main thread.

### Workflow 8: Multiplayer Architecture
**MANDATORY — READ ALL**: [Multiplayer Networking](references/multiplayer_networking.md) → [Server Architecture](references/server_architecture.md) → [Adapt Single→Multi](references/adapt_single_multiplayer.md)
**Do NOT load** single-player genre blueprints.

- Client sends Input, Server calculates Outcome. The Client NEVER determines damage, position deltas, or inventory changes.
- Use Client-Side Prediction with server reconciliation: predict locally, correct from server snapshot. Hides up to ~150ms of latency.
- `MultiplayerSpawner` handles replication in Godot 4. Configure it per scene, not globally.

### Workflow 9: Premium UI/UX
**MANDATORY**: [UI Theming](references/ui_theming.md) → [UI Containers](references/ui_containers.md) → [Tweening](references/tweening.md) → [Rich Text](references/ui_rich_text.md)

- NEVER override colors in Inspector. Create a `.theme` resource as the single source of truth for global skinning.
- Every interactive element should have micro-animation: `Tween` scale pulse on buttons, `RichTextEffect` on damage numbers, `AnimationPlayer` on panel transitions.
- Use `Control.FOCUS_MODE_ALL` and test full keyboard/gamepad navigation. Inaccessible UI blocks console certification.

### Workflow 10: Graphics & Atmosphere
**MANDATORY**: [3D Lighting](references/3d_lighting.md) → [3D Materials](references/3d_materials.md) → [Shader Basics](references/shaders_basics.md) → [Particles](references/particles.md)

- Use `GPUParticles3D` for environment effects (rain, fog, fire). Use `CPUParticles` ONLY when script must read/write individual particle positions.
- Always set `visibility_aabb` manually on GPU particles. The auto-calculated AABB is often wrong, causing particles to disappear when the emitter is off-screen.
- For stylized looks: use `CanvasItem` shaders with `screen_texture` for post-processing in 2D. In 3D, use a `WorldEnvironment` with custom `Environment` resource.
- `ReflectionProbe` vs `VoxelGI` vs `SDFGI`: Probes are cheap/static, VoxelGI is medium/baked, SDFGI is expensive/dynamic. Choose based on your platform budget (see Part 5).

---

## 🚫 Part 4: The Expert NEVER List

Each rule includes the **non-obvious reason** — the thing only shipping experience teaches.

1. **NEVER use `get_tree().root.get_node("...")`** — Absolute paths break when ANY ancestor is renamed or reparented. Use `%UniqueNames`, `@export NodePath`, or signal-based discovery.
2. **NEVER use `load()` inside a loop or `_process`** — Synchronous disk read blocks the ENTIRE main thread. Use `preload()` at script top for small assets, `ResourceLoader.load_threaded_request()` for large ones.
3. **NEVER `queue_free()` while external references exist** — Parent nodes or arrays holding refs will get "Deleted Object" errors. Clean up refs in `_exit_tree()` and set them to `null` before freeing.
4. **NEVER put gameplay logic in `_draw()`** — `_draw()` is called on the rendering thread. Mutating game state causes race conditions with `_physics_process`.
5. **NEVER use `Area2D` for 1000+ overlapping objects** — Each overlap check has O(n²) broadphase cost. Use `ShapeCast2D`, `PhysicsDirectSpaceState2D.intersect_shape()`, or Server APIs for bullet-hell patterns.
6. **NEVER mutate external state from a component** — If `HealthComponent` calls `$HUD.update_bar()`, deleting the HUD crashes the game. Components emit signals; listeners decide how to respond.
7. **NEVER use `await` in `_physics_process`** — `await` yields execution, meaning the physics step skips frames. Move async operations to a separate method triggered by a signal.
8. **NEVER use `String` keys in hot-path dictionary lookups** — String hashing is O(n). Use `StringName` (`&"key"`) for O(1) pointer comparisons, or integer enums.
9. **NEVER store `Callable` references to freed objects** — Crashes silently or throws errors. Disconnect signals in `_exit_tree()` or use `CONNECT_ONE_SHOT`.
10. **NEVER use `_process` for 1000+ entities** — Each `_process` call has per-node SceneTree overhead. Use a single `Manager._process` that iterates an array of data structs (Data-Oriented pattern), or use Server APIs directly.
11. **NEVER use `Tween` on a node that may be freed** — If a node is `queue_free()`'d while a Tween runs, it errors. Kill tweens in `_exit_tree()` or bind to SceneTree: `get_tree().create_tween()`.
12. **NEVER request data FROM `RenderingServer` or `PhysicsServer` in `_process`** — These servers run asynchronously. Calling getter functions forces a synchronous stall that kills performance. The APIs are intentionally designed to be write-only in hot paths.
13. **NEVER use `call_deferred()` as a band-aid for initialization order bugs** — It masks architectural problems (dependency on tree order). Fix the actual dependency with explicit initialization signals or `@onready`.
14. **NEVER create circular signal connections** — Node A connects to B, B connects to A. This creates infinite loops on the first emit. Use a mediator pattern (Signal Bus) to break cycles.
15. **NEVER let inheritance exceed 3 levels** — Beyond 3, debugging `super()` chains is a nightmare. Use composition (`Node` children) to add behaviors instead.

---

## 📊 Part 5: Performance Budgets (Concrete Numbers)

| Metric | Mobile Target | Desktop Target | Expert Note |
| :--- | :--- | :--- | :--- |
| **Draw Calls** | < 100 (2D), < 200 (3D) | < 500 | `MultiMeshInstance` for foliage/debris |
| **Triangle Count** | < 100K visible | < 1M visible | LOD system mandatory above 500K |
| **Texture VRAM** | < 512MB | < 2GB | VRAM Compression: ETC2 (mobile), BPTC (desktop) |
| **Script Time** | < 4ms per frame | < 8ms per frame | Move hot loops to Server APIs |
| **Physics Bodies** | < 200 active | < 1000 active | Use `PhysicsServer` direct API for mass sim |
| **Particles** | < 2000 total | < 10000 total | GPU particles, set `visibility_aabb` manually |
| **Audio Buses** | < 8 simultaneous | < 32 simultaneous | Use [Audio Systems](references/audio-systems.md) bus routing |
| **Save File Size** | < 1MB | < 50MB | Seed + Delta pattern for procedural worlds |
| **Scene Load Time** | < 500ms | < 2s | `ResourceLoader.load_threaded_request()` |

---

## ⚙️ Part 6: Server APIs — The Expert Performance Escape Hatch

This is knowledge most Godot developers never learn. When the scene tree becomes a bottleneck, bypass it entirely using Godot's low-level Server APIs.

### When to Drop to Server APIs
- **10K+ rendered instances** (sprites, meshes): Use `RenderingServer` with RIDs instead of `Sprite2D`/`MeshInstance3D` nodes.
- **Bullet-hell / particle systems** with script interaction: Use `PhysicsServer2D` body creation instead of `Area2D` nodes.
- **Mass physics simulation**: Use `PhysicsServer3D` directly for ragdoll fields, debris, or fluid-like simulations.

### The RID Pattern (Expert)
Server APIs communicate through **RID** (Resource ID) — opaque handles to server-side objects. Critical rules:
```gdscript
# Create server-side canvas item (NO node overhead)
var ci_rid := RenderingServer.canvas_item_create()
RenderingServer.canvas_item_set_parent(ci_rid, get_canvas_item())

# CRITICAL: Keep resource references alive. RIDs don't count as references.
# If the Texture resource is GC'd, the RID becomes invalid silently.
var texture: Texture2D = preload("res://sprite.png")
RenderingServer.canvas_item_add_texture_rect(ci_rid, Rect2(-texture.get_size() / 2, texture.get_size()), texture)
```

### Threading with Servers
- The scene tree is **NOT thread-safe**. But Server APIs (RenderingServer, PhysicsServer) ARE thread-safe when enabled in Project Settings.
- You CAN build scene chunks (instantiate + add_child) on a worker thread, but MUST use `add_child.call_deferred()` to attach them to the live tree.
- GDScript Dictionaries/Arrays: reads and writes across threads are safe, but **resizing** (append, erase, resize) requires a `Mutex`.
- **NEVER** load the same `Resource` from multiple threads simultaneously — use one loading thread.

---

## 🧩 Part 7: Expert Code Patterns

### The Component Registry
```gdscript
class_name Entity extends CharacterBody2D

var _components: Dictionary = {}

func _ready() -> void:
    for child in get_children():
        if child.has_method("get_component_name"):
            _components[child.get_component_name()] = child

func get_component(component_name: StringName) -> Node:
    return _components.get(component_name)
```

### Dead Instance Safe Signal Handler
```gdscript
func _on_damage_dealt(target: Node, amount: int) -> void:
    if not is_instance_valid(target): return
    if target.is_queued_for_deletion(): return
    target.get_component(&"health").apply_damage(amount)
```

### The Async Resource Loader
```gdscript
func _load_level_async(path: String) -> void:
    ResourceLoader.load_threaded_request(path)
    while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
        await get_tree().process_frame
    var scene: PackedScene = ResourceLoader.load_threaded_get(path)
    add_child(scene.instantiate())
```

### State Machine Transition Guard
```gdscript
func can_transition_to(new_state: StringName) -> bool:
    match name:
        &"Dead": return false  # Terminal state
        &"Stunned": return new_state == &"Idle"  # Can only recover to Idle
        _: return true
```

### Thread-Safe Chunk Loader (Server API Pattern)
```gdscript
func _load_chunk_threaded(chunk_pos: Vector2i) -> void:
    # Build scene chunk OFF the active tree (thread-safe)
    var chunk := _generate_chunk(chunk_pos)
    # Attach to live tree from main thread ONLY
    _world_root.add_child.call_deferred(chunk)
```

---

## 🔥 Part 8: Godot 4.x Gotchas (Veteran-Only)

1. **`@export` Resources are shared by default**: Multiple scene instances ALL share the same `Resource`. Use `resource.duplicate()` in `_ready()` or enable "Local to Scene" checkbox. This is the #1 most reported Godot 4 bug by newcomers.
2. **Signal syntax silently fails**: `connect("signal_name", target, "method")` (Godot 3 syntax) compiles but does nothing in Godot 4. Must use `signal_name.connect(callable)`.
3. **`Tween` is no longer a Node**: Created via `create_tween()`, bound to the creating node's lifetime. If that node is freed, the Tween dies. Use `get_tree().create_tween()` for persistent tweens.
4. **`PhysicsBody` layers vs masks**: `collision_layer` = "what I am". `collision_mask` = "what I scan for". Setting both to the same value causes self-collision or missed detections.
5. **`StringName` vs `String` in hot paths**: `StringName` (`&"key"`) uses pointer comparison (O(1)). `String` uses character comparison (O(n)). Always use `StringName` for dictionary keys in `_process`.
6. **`@onready` timing**: Runs AFTER `_init()` but DURING `_ready()`. If you need constructor-time setup, use `_init()`. If you need tree access, use `@onready` or `_ready()`. Mixing them causes nulls.
7. **Server query stalls**: Calling `RenderingServer` or `PhysicsServer` getter functions in `_process` forces a synchronous pipeline flush. These servers run async — requesting data from them stalls the entire pipeline until the server catches up.
8. **`move_and_slide()` API change**: Returns `bool` (whether collision occurred). Velocity is now a property, not a parameter. `velocity = dir * speed` before calling `move_and_slide()`.

---

## 📂 Part 9: Module Directory (86 Blueprints)

> [!IMPORTANT]
> Load ONLY the modules needed for your current workflow. Use the Decision Matrix in Part 2 to determine which chain to follow.

### Architecture & Foundation
[Foundations](references/project_foundations.md) | [Composition](references/composition.md) | [App Composition](references/composition_apps.md) | [Signals](references/signal_architecture.md) | [Autoloads](references/autoload_architecture.md) | [States](references/state_machine_advanced.md) | [Resources](references/resource_data_patterns.md) | [Templates](references/project_templates.md) | [MCP Setup](references/mcp_setup.md) | [Skill Discovery](references/skill_discovery.md) | [Skill Judge](references/skill_judge.md)

### GDScript & Testing
[GDScript Mastery](references/gdscript_mastery.md) | [Testing Patterns](references/testing_patterns.md) | [Debugging/Profiling](references/debugging_profiling.md) | [Performance Optimization](references/performance_optimization.md)

### 2D Systems
[2D Animation](references/2d_animation.md) | [2D Physics](references/2d_physics.md) | [Tilemaps](references/tilemap_mastery.md) | [Animation Player](references/animation_player.md) | [Animation Tree](references/animation_tree_mastery.md) | [CharacterBody2D](references/characterbody_2d.md) | [Particles](references/particles.md) | [Tweening](references/tweening.md) | [Shader Basics](references/shaders_basics.md) | [Camera Systems](references/camera_systems.md)

### 3D Systems
[3D Lighting](references/3d_lighting.md) | [3D Materials](references/3d_materials.md) | [3D World Building](references/3d_world_building.md) | [Physics 3D](references/physics_3d.md) | [Navigation/Pathfinding](references/navigation_pathfinding.md) | [Procedural Generation](references/procedural_generation.md)

### Gameplay Mechanics
[Abilities](references/ability_system.md) | [Combat](references/combat_system.md) | [Dialogue](references/dialogue_system.md) | [Economy](references/economy_system.md) | [Inventory](references/inventory_system.md) | [Questing](references/quest_system.md) | [RPG Stats](references/rpg_stats.md) | [Turn System](references/turn_system.md) | [Audio](references/audio_systems.md) | [Scene Transitions](references/scene_management.md) | [Save/Load](references/save_load_systems.md) | [Secrets](references/mechanic-secrets.md) | [Collections](references/game-loop-collection.md) | [Waves](references/game-loop-waves.md) | [Harvesting](references/game-loop-harvest.md) | [Time Trials](references/game-loop-time-trial.md) | [Revival](references/mechanic-revival.md)

### UI & UX
[UI Containers](references/ui_containers.md) | [Rich Text](references/ui_rich_text.md) | [Theming](references/ui_theming.md) | [Input Handling](references/input_handling.md) | [Seasonal Theming](references/theme-easter.md)

### Connectivity & Platforms
[Multiplayer](references/multiplayer_networking.md) | [Server Logic](references/server_architecture.md) | [Export Builds](references/export-builds.md) | [Desktop](references/platform_desktop.md) | [Mobile](references/platform_mobile.md) | [Web](references/platform_web.md) | [Console](references/platform_console.md) | [VR](references/platform_vr.md)

### Adaptation Guides
[2D→3D](references/adapt_2d_3d.md) | [3D→2D](references/adapt_3d_2d.md) | [Desktop→Mobile](references/adapt_desktop_mobile.md) | [Mobile→Desktop](references/adapt_mobile_desktop.md) | [Single→Multi](references/adapt_single_multiplayer.md)

### Genre Blueprints
[Action RPG](references/action_rpg.md) | [Shooter](references/shooter.md) | [RTS](references/rts.md) | [MOBA](references/moba.md) | [Rogue-like](references/roguelike.md) | [Survival](references/survival.md) | [Open World](references/open_world.md) | [Metroidvania](references/metroidvania.md) | [Platformer](references/platformer.md) | [Fighting](references/fighting.md) | [Stealth](references/stealth.md) | [Sandbox](references/sandbox.md) | [Horror](references/horror.md) | [Puzzle](references/puzzle.md) | [Racing](references/racing.md) | [Rhythm](references/rhythm.md) | [Sports](references/sports.md) | [Battle Royale](references/battle_royale.md) | [Card Game](references/card_game.md) | [Visual Novel](references/visual_novel.md) | [Romance](references/romance.md) | [Simulation](references/simulation.md) | [Tower Defense](references/tower_defense.md) | [Idle Clicker](references/idle_clicker.md) | [Party](references/party.md) | [Educational](references/educational.md)

### MCP Tooling
[MCP Scene Builder](references/mcp_scene_builder.md)

---

## 🐛 Part 10: Expert Diagnostic Patterns

### The "Invisible Node" Bug
**Symptom**: Node exists in tree but isn't rendering.
**Expert diagnosis chain**: `visible` property → `z_index` → parent `CanvasLayer` wrong layer → `modulate.a == 0` → behind camera's `near` clip (3D) → `SubViewport.render_target_update_mode` not set → `CanvasItem` not in any `CanvasLayer` (renders behind everything).

### The "Input Eaten" Bug
**Symptom**: Clicks or key presses ignored intermittently.
**Expert diagnosis**: Another `Control` node with `mouse_filter = STOP` overlapping the target. Or, modal `PopupMenu` consuming unhandled input. Or, `_unhandled_input()` in another script calling `get_viewport().set_input_as_handled()`.

### The "Physics Jitter" Bug
**Symptom**: Character vibrates at surface contacts.
**Expert diagnosis**: `Safe Margin` too large. Or, `_process` used for movement instead of `_physics_process` (interpolation mismatch). Or, collision shapes overlap at spawn (push each other apart permanently).

### The "Memory Leak"
**Symptom**: RAM grows steadily during play.
**Expert diagnosis**: `queue_free()` called but reference held in Array/Dictionary. Or, signals connected with `CONNECT_REFERENCE_COUNTED` without cleanup. Use Profiler "Objects" tab to find orphaned instances. Search for `Node` instances without a parent.

### The "Frame Spike"
**Symptom**: Smooth FPS but periodic drops.
**Expert diagnosis**: GDScript GC pass. Or, synchronous `load()` for a large resource. Or, `NavigationServer` rebaking. Or, Server API query stall (requesting data from `RenderingServer` in `_process`). Profile with built-in Profiler → look for function-level spikes.

---

## Reference
- [Godot 4.x Official Documentation](https://docs.godotengine.org/en/stable/)
- [Godot Engine GitHub Discussions](https://github.com/godotengine/godot/discussions)

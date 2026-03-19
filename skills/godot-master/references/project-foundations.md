---
name: godot-project-foundations
description: "Expert blueprint for Godot 4 project organization (feature-based folders, naming conventions, version control). Enforces snake_case files, PascalCase nodes, %SceneUniqueNames, and .gitignore best practices. Use when starting new projects or refactoring structure. Keywords project organization, naming conventions, snake_case, PascalCase, feature-based, .gitignore, .gdignore."
---

# Project Foundations

Feature-based organization, consistent naming, and version control hygiene define professional Godot projects.

## Available Scripts

> **MANDATORY - For New Projects**: Before scaffolding, read [`project_bootstrapper.gd`](../scripts/project_foundations_project_bootstrapper.gd) - Auto-generates feature folders and .gitignore.

### [project_bootstrapper.gd](../scripts/project_foundations_project_bootstrapper.gd)
Expert project scaffolding tool for auto-generating feature folders and .gitignore.

### [runtime_configurator.gd](../scripts/project_foundations_runtime_configurator.gd)
Expert pattern for applying high-performance profiles (ticks, FPS) and saving `override.cfg`.

### [managed_autoload.gd](../scripts/project_foundations_managed_autoload.gd)
Advanced Singleton pattern with `RefCounted` delegation to avoid SceneTree bloat.

### [base_data_resource.gd](../scripts/project_foundations_base_data_resource.gd)
Reactive Resource foundation using `emit_changed()` for data-driven pipelines.

### [advanced_telemetry_logger.gd](../scripts/project_foundations_advanced_telemetry_logger.gd)
Custom OS-level `Logger` implementation to capture engine output for crash reporting.

### [threaded_task_worker.gd](../scripts/project_foundations_threaded_task_worker.gd)
Robust `WorkerThreadPool` implementation with `Mutex` synchronization.

### [async_resource_loader.gd](../scripts/project_foundations_async_resource_loader.gd)
Threaded non-blocking scene loading with progress status.

### [action_buffer_input.gd](../scripts/project_foundations_action_buffer_input.gd)
Foundational `_unhandled_input` buffer to decouple hardware events from frame-rate.

### [global_event_bus.gd](../scripts/project_foundations_global_event_bus.gd)
Strongly-typed global Signal Bus for system decoupling.

### [build_metadata_provider.gd](../scripts/project_foundations_build_metadata_provider.gd)
Native extraction of project version and CI/CD build metadata.

### [node_pooling_system.gd](../scripts/project_foundations_node_pooling_system.gd)
Thread-safe Object Pool for high-frequency scene instantiation.

> **Do NOT Load** dependency_auditor.gd unless troubleshooting loading errors.


## NEVER Do (Expert Anti-Patterns)

### Global Architecture
- **NEVER group by file type** —  `/scripts`, `/sprites` folders. Nightmare maintainability. Use feature-based: `/player`, `/ui`.
- **NEVER mix snake_case and PascalCase in files** — Standard: snake_case for files, PascalCase for nodes.
- **NEVER use hardcoded get_node() paths** — Brittle on reparenting. Use `%SceneUniqueNames` for stable references.
- **NEVER use monolithic Autoloads** — Avoid managers that hold visual node references; keep singletons focused on pure data or RefCounted delegation.

### Resource Management
- **NEVER forget .gitignore**  — Committing `.godot/` folder = 100MB+ bloat + conflicts.
- **NEVER skip .gdignore for raw assets** — Design source files (`.psd`, `.blend`) in root will be imported unless ignored.
- **NEVER modify globally shared Resources directly** — Strictly call `duplicate(true)` for unique instances with independent state.

### Performance & Threading
- **NEVER block the main thread with `load()`** — Strictly use `ResourceLoader.load_threaded_request()` for async scene transitions.
- **NEVER modify the SceneTree from a background thread** — Strictly use `call_deferred()` for thread-to-main-thread synchronization.
- **NEVER skip Mutex locking during pooled access** — Strictly ensure thread-safety when using a shared `WorkerThreadPool` or Object Pool.
- **NEVER use `_process()` for precise input** — Tied to visual framerate. Strictly use `_unhandled_input()` to capture exact, frame-independent events.

---

### 1. Naming Conventions
- **Files & Folders**: Always use `snake_case`. (e.g., `player_controller.gd`, `main_menu.tscn`).
    - *Exception*: C# scripts should use `PascalCase` to match class names.
- **Node Names**: Always use `PascalCase` (e.g., `PlayerSprite`, `CollisionShape2D`).
- **Unique Names**: Use `%SceneUniqueNames` for frequently accessed nodes to avoid brittle `get_node()` paths.

### 2. Feature-Based Organization
Instead of grouping by *type* (e.g., `/scripts`, `/sprites`), group by *feature* (the "What", not the "How").

**Correct Structure:**
```
/project.godot
/common/           # Global resources, themes, shared scripts
/entities/
    /player/       # Everything related to player
        player.tscn
        player.gd
        player_sprite.png
    /enemy/
/ui/
    /main_menu/
/levels/
/addons/           # Third-party plugins
```

### 3. Version Control
- Always include a `.gitignore` tailored for Godot (ignoring `.godot/` folder and import artifacts).
- Use `.gdignore` in folders that Godot should not scan/import (e.g., raw design source files).

## Workflow: Scaffolding a New Project

When asked to "Setup a project" or "Start a new game":

1. **Initialize Root**: Ensure `project.godot` exists.
2. **Create Core Folders**:
   - `entities/`
   - `ui/`
   - `levels/`
   - `common/`
3. **Setup Git**: Create a comprehensive `.gitignore`.
4. **Documentation**: Create a `README.md` explaining the feature-based structure.

## Reference
- Official Docs: `tutorials/best_practices/project_organization.rst`
- Official Docs: `tutorials/best_practices/scene_organization.rst`


### Related
- Master Skill: [godot-master](../SKILL.md)

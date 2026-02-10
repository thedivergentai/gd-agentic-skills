---
name: godot-project-foundations
description: "Expert blueprint for Godot 4 project organization (feature-based folders, naming conventions, version control). Enforces snake_case files, PascalCase nodes, %SceneUniqueNames, and .gitignore best practices. Use when starting new projects or refactoring structure. Keywords project organization, naming conventions, snake_case, PascalCase, feature-based, .gitignore, .gdignore."
---

# Project Foundations

Feature-based organization, consistent naming, and version control hygiene define professional Godot projects.

## Available Scripts

> **MANDATORY - For New Projects**: Before scaffolding, read [`project_bootstrapper.gd`](scripts/project_bootstrapper.gd) - Auto-generates feature folders and .gitignore.

### [project_bootstrapper.gd](scripts/project_bootstrapper.gd)
Expert project scaffolding tool for auto-generating feature folders and .gitignore.

### [scene_naming_validator.gd](scripts/scene_naming_validator.gd)
Scans entire project for snake_case/PascalCase violations. Run before PRs.

### [dependency_auditor.gd](scripts/dependency_auditor.gd)
Detects circular scene dependencies and coupling issues. Critical for projects >50 scenes.

### [feature_scaffolder.gd](scripts/feature_scaffolder.gd)
Generates complete feature folders with base scenes, scripts, and subfolders.

> **Do NOT Load** dependency_auditor.gd unless troubleshooting loading errors or auditing large projects.


## NEVER Do in Project Organization

- **NEVER group by file type** —  `/scripts`, `/sprites`, `/sounds` folders? Nightmare maintainability. Use feature-based: `/player`, `/enemies`, `/ui`.
- **NEVER mix snake_case and PascalCase in files** — `PlayerController.gd` vs `player_controller.gd`? Pick one. Official standard: snake_case for files, PascalCase for nodes.
- **NEVER forget .gitignore**  — Committing `.godot/` folder = 100MB+ bloat + merge conflicts. ALWAYS include Godot-specific .gitignore.
- **NEVER use hardcoded get_node() paths** — `get_node("../../../Player/Sprite2D")` breaks on scene reparenting. Use `%SceneUniqueNames` for stable references.
- **NEVER skip .gdignore for raw assets** — Design source files (`.psd`, `.blend`) in project root = Godot imports them. Add `.gdignore` to exclude from import process.

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
- Master Skill: [godot-master](../godot-master/SKILL.md)

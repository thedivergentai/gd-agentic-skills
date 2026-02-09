---
name: godot-mcp-scene-builder
description: "[MCP WRAPPER] Programmatically create/modify Godot scenes using Godot MCP tools. Orchestrates mcp_godot_create_scene, mcp_godot_add_node, mcp_godot_load_sprite into agentic workflows. Use when user requests scene generation/automation via MCP. Keywords MCP, scene automation, programmatic scene building, node hierarchy."
---

# MCP Scene Builder

High-level agentic interface for low-level Godot MCP tools to build scenes from scratch.

## NEVER Do in MCP Scene Building

- **NEVER skip design phase** — Jumping straight to `mcp_godot_add_node` without planning hierarchy = spaghetti scenes. ALWAYS draft node tree first.
- **NEVER assume scene exists before adding nodes** — `mcp_godot_add_node` on non-existent scene = error. Must call `mcp_godot_create_scene` FIRST.
- **NEVER use absolute paths in MCP calls** — `texturePath="C:/Users/..."` breaks on other machines. Use `res://` paths only.
- **NEVER skip verification step** — MCP creates .tscn files but doesn't validate. ALWAYS call `mcp_godot_run_project` or `mcp_godot_launch_editor` to verify no errors.
- **NEVER add CollisionShape2D without setting shape** — MCP adds node but `shape` property is null by default. Must manually set or scene is broken.

---

## Available Scripts

### [scene_builder_manifest.gd](scripts/scene_builder_manifest.gd)
Resource definition for declarative scene building via MCP.

## Available MCP Tools Summary
- `mcp_godot_create_scene`: Initializes a `.tscn` file.
- `mcp_godot_add_node`: Adds a node to an existing scene.
- `mcp_godot_load_sprite`: Assigns a texture to a `Sprite2D` node.
- `mcp_godot_run_project`: Spawns the Godot editor to verify the result.

## Workflow: Building a Scene

When asked to "Create a scene", "Make a character", or "Setup a level":

1. **Design Phase**:
   - Determine the Root node type (e.g., `CharacterBody2D`, `Node3D`, `Control`).
   - Draft a node hierarchy (e.g., Root -> Sprite2D, CollisionShape2D).

2. **Execution Phase (MCP Pipeline)**:
   - **Step 1**: Call `mcp_godot_create_scene` to create the file.
   - **Step 2**: Sequentially call `mcp_godot_add_node` for each child.
   - **Step 3** (Optional): If sprites are needed, call `mcp_godot_load_sprite`.
   - **Step 4**: (Critical for verifying) Call `mcp_godot_run_project` or `mcp_godot_launch_editor`.

3. **Optimization Phase**:
   - Apply `godot-gdscript-mastery` standards when attaching scripts.

## Example: Creating a Basic 2D Player

**Prompt**: "Create a 2D player scene with a sprite and collision."

**Plan**:
1. `mcp_godot_create_scene(scenePath="player.tscn", rootNodeType="CharacterBody2D")`
2. `mcp_godot_add_node(scenePath="player.tscn", nodeType="Sprite2D", nodeName="Skin", parentNodePath=".")`
3. `mcp_godot_add_node(scenePath="player.tscn", nodeType="CollisionShape2D", nodeName="Hitbox", parentNodePath=".")`
4. `mcp_godot_load_sprite(scenePath="player.tscn", nodePath="Skin", texturePath="res://icon.svg")`

## Verification
The agent must verify that the scene opens in the editor without errors.


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)

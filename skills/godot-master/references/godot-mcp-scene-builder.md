> [!NOTE]
> **Resource Context**: This module provides expert patterns for **MCP Scene Builder [MCP WRAPPER]**. Accessed via Godot Master.

# MCP Scene Builder [MCP WRAPPER]

An agentic interface designed to orchestrate low-level Godot MCP tools. This module provides high-level patterns for programmatically generating, modifying, and scaffolding Godot scenes entirely through automated workflows.

## Available Scripts

### [batch_scaffold_builder.gd](../scripts/godot-mcp-scene-builder_batch_scaffold_builder.gd)
An automation script for generating complex node hierarchies in bulk. This script takes a structural manifest (JSON or Dictionary) and calls the appropriate MCP tools sequentially to build out character skeletons, UI layouts, or entire level scaffolds programmatically.

### [scene_builder_manifest.gd](../scripts/godot-mcp-scene-builder_scene_builder_manifest.gd)
A `Resource`-based definition for declarative scene building. It allows a user (or agent) to define a scene's intended structure in a single file, which can then be parsed and executed by the MCP toolchain to ensure consistency across multiple generated scenes.


## NEVER Do

- **NEVER skip the Design/Blueprint phase** — Blindly calling `mcp_godot_add_node` without a clear hierarchy plan leads to unusable and messy scenes. ALWAYS draft the tree structure (e.g., Root -> Visuals -> Colliders) before execution.
- **NEVER attempt to add nodes to a non-existent scene** — The MCP toolchain is strictly sequential. You MUST call `mcp_godot_create_scene` to initialize the `.tscn` file before any subsequent node addition or modification calls.
- **NEVER use local absolute file paths in MCP calls** — Hardcoding `texturePath="C:/Users/name/Desktop/icon.png"` will break the project as soon as it's shared or moved. ALWAYS use **Godot's `res://` protocol** (e.g., `res://assets/images/icon.png`).
- **NEVER assume a generated scene is "Valid" without verification** — Automated tools can produce files that technically exist but contain logical errors (e.g., a PhysicsBody without a shape). ALWAYS call `mcp_godot_run_project` to verify the scene loads correctly in the engine.
- **NEVER add collision bodies without their required shapes** — An MCP call might add a `CollisionShape3D` node, but the `shape` property will be `null`. You must follow up with a property setting call or the node will remain in an "Error" state in Godot.

---

## The MCP Pipeline Workflow
1. **Scaffold**: Initialize the Root node and basic hierarchy (JSON manifest recommended).
2. **Assign**: Link textures via `mcp_godot_load_sprite` and assign signals.
3. **Verify**: Launch the editor using the MCP verification tool to ensure zero "Scene Corruption" warnings.

## Declarative Scene Building (Manifests)
Instead of 20 individual tool calls, use a **Manifest Dictionary**:
```json
{
  "root": "CharacterBody2D",
  "children": [
    {"name": "Sprite", "type": "Sprite2D"},
    {"name": "Collision", "type": "CollisionShape2D"}
  ]
}
```
This manifest acts as the "Source of Truth" for the `batch_scaffold_builder`.

## Integrating with AI Workflows
This skill is designed for agents to:
- Generate requested character scenes (e.g., "Make me a basic enemy").
- Automatically organize project assets into a standardized folder structure.
- Auto-generate UI screens from a layout description (e.g., "A Main Menu with 3 buttons").

## Reference
- [Godot Docs: Developing with MCP](https://docs.mcp.run/godot)
- [Master Skill: godot-master](../godot-master/SKILL.md)

# skills/mcp-scene-builder/scripts/scene_builder_manifest.gd
extends Resource

## Scene Builder Manifest Expert Pattern
## declarative definition for creating scenes via MCP or scripts.

class_name SceneBuilderManifest

@export var root_type: String = "Node2D"
@export var scene_name: String = "NewScene"
@export var nodes: Array[SceneNodeDef] = []

class SceneNodeDef extends Resource:
	@export var name: String
	@export var type: String
	@export var parent: String = "." # Path relative to root
	@export var properties: Dictionary = {}
	@export var script_path: String = ""

# Helper to validate creation (Pseudo-code as actual creation is via MCP)
func validate() -> PackedStringArray:
	var errors = PackedStringArray()
	if root_type.is_empty(): errors.append("Root type missing")
	if scene_name.is_empty(): errors.append("Scene name missing")
	return errors

## EXPERT USAGE:
## Define a manifest, then use an Agent to "Build the scene defined in manifest.tres"

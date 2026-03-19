# skills/project-foundations/scripts/feature_scaffolder.gd
@tool
extends EditorScript

## Feature Scaffolder Expert Pattern
## Generates complete feature folders with base scenes and scripts.

@export var feature_name: String = "new_feature"
@export var feature_type: String = "entity"  # entity, ui, system

const TEMPLATES := {
	"entity": {
		"scene": "base_entity.tscn",
		"script": "entity_template.gd",
		"folders": ["states", "abilities"]
	},
	"ui": {
		"scene": "base_ui.tscn",
		"script": "ui_controller.gd",
		"folders": ["components", "themes"]
	},
	"system": {
		"script": "system_template.gd",
		"folders": ["data", "processors"]
	}
}

func _run() -> void:
	if feature_name.is_empty():
		printerr("❌ Feature name cannot be empty")
		return
		
	var feature_path := "res://%ss/%s/" % [feature_type, feature_name]
	
	# Create feature folder
	if DirAccess.dir_exists_absolute(feature_path):
		printerr("❌ Feature '%s' already exists" % feature_name)
		return
		
	DirAccess.make_dir_recursive_absolute(feature_path)
	print("✓ Created %s" % feature_path)
	
	# Create template files
	var template := TEMPLATES.get(feature_type, {})
	
	if template.has("scene"):
		_create_base_scene(feature_path + feature_name + ".tscn")
		
	if template.has("script"):
		_create_base_script(feature_path + feature_name + ".gd")
		
	# Create subfolders
	for subfolder in template.get("folders", []):
		var sub_path := feature_path + subfolder
		DirAccess.make_dir_recursive_absolute(sub_path)
		print("✓ Created %s" % sub_path)
	
	# Create README
	_create_readme(feature_path)
	
	print("✅ Feature '%s' scaffolded successfully!" % feature_name)

func _create_base_scene(path: String) -> void:
	# Create minimal scene structure
	var scene := PackedScene.new()
	var root: Node
	
	match feature_type:
		"entity":
			root = CharacterBody2D.new()
		"ui":
			root = Control.new()
		_:
			root = Node.new()
			
	root.name = feature_name.capitalize().replace(" ", "")
	scene.pack(root)
	ResourceSaver.save(scene, path)
	print("✓ Created scene: %s" % path)

func _create_base_script(path: String) -> void:
	var script_content := """extends %s

## %s
## TODO: Add description

func _ready() -> void:
	pass

## EXPERT NOTE:
## Follow single responsibility principle.
## Keep scripts under 300 lines - break into modules if larger.
""" % [_get_base_class(), feature_name.capitalize()]

	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(script_content)
	print("✓ Created script: %s" % path)

func _get_base_class() -> String:
	match feature_type:
		"entity": return "CharacterBody2D"
		"ui": return "Control"
		_: return "Node"

func _create_readme(feature_path: String) -> void:
	var readme := """# %s

## Purpose
TODO: Describe this feature

## Structure
- Main scene: `%s.tscn`
- Main script: `%s.gd`

## Dependencies
TODO: List related features/systems

## Usage
TODO: How to integrate this feature
""" % [feature_name.capitalize(), feature_name, feature_name]

	var file := FileAccess.open(feature_path + "README.md", FileAccess.WRITE)
	file.store_string(readme)
	print("✓ Created README")

## EXPERT NOTE:
## Customize TEMPLATES dict for your project's patterns.
## Advanced: Generate test scenes automatically with GUT framework.
## Pro tip: Bind this to EditorPlugin tool button for one-click scaffolding.

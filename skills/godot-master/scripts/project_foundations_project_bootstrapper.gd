# skills/project-foundations/code/project_bootstrapper.gd
@tool
extends EditorScript

## Project Foundations Expert Pattern
## Automatically scaffolds a professional feature-based structure.

const CORE_FOLDERS = [
    "res://common",
    "res://entities",
    "res://levels",
    "res://ui",
    "res://assets",
    "res://data"
]

func _run() -> void:
    print("--- Starting Project Bootstrap ---")
    
    # 1. Feature-Based Folder Creation
    # Expert logic: Group objects by feature/entity rather than by 
    # file type (e.g. res://entities/player/player.tscn over res://scenes/player.tscn).
    for folder in CORE_FOLDERS:
        if not DirAccess.dir_exists_absolute(folder):
            DirAccess.make_dir_recursive_absolute(folder)
            print("[CREATED] ", folder)
            
    # 2. Sub-folder Scaffolding (The Module Pattern)
    _create_subfolder("res://entities/player")
    _create_subfolder("res://common/globals")
    
    # 3. .gdignore Enforcement
    # Ensure specific folders are IGNORED by Godot's importer 
    # if they contain non-game assets (e.g. blend files).
    _enforce_gdignore("res://assets/raw_source")

    print("--- Bootstrap Complete ---")

func _create_subfolder(path: String) -> void:
    if not DirAccess.dir_exists_absolute(path):
        DirAccess.make_dir_recursive_absolute(path)
        print("[CREATED] ", path)

func _enforce_gdignore(path: String) -> void:
    if DirAccess.dir_exists_absolute(path):
        var file = FileAccess.open(path + "/.gdignore", FileAccess.WRITE)
        file.store_string("")

## EXPERT NOTE:
## Use 'Project Setup CLI': Tie this script to a custom EditorPlugin 
## button to allow artists and designers to quickly 'Scaffold New Feature' 
## with all 'base_scenes' and 'logic_scripts' pre-populated.
## NEVER put code files in the root folder. For 'project-foundations', 
## enforce a strict 'res://common' layer for Autoloads and 'res://data' 
## for JSON/Resource databases.

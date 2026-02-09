# skills/mcp-scene-builder/code/batch_scaffold_builder.gd
@tool
extends EditorScript

## Batch Scaffold Builder Expert Pattern
## Automates project structure and UI hierarchy creation.

func _run() -> void:
    var root_path = "res://scenes/"
    
    # 1. Automated Directory Scaffolding
    var dirs = ["core", "entities", "ui", "world", "assets"]
    for dir in dirs:
        var path = root_path + dir
        if not DirAccess.dir_exists_absolute(path):
            DirAccess.make_dir_recursive_absolute(path)
            print("[SCAFFOLD] Created directory: ", path)

    # 2. Standard UI Hierarchy Instantiation
    _build_standard_ui()

func _build_standard_ui() -> void:
    var ui_root = CanvasLayer.new()
    ui_root.name = "UIRoot"
    
    var hud = Control.new()
    hud.name = "HUD"
    hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    ui_root.add_child(hud)
    
    var pause_menu = Control.new()
    pause_menu.name = "PauseMenu"
    pause_menu.visible = false
    ui_root.add_child(pause_menu)
    
    # Pack and save
    var packed = PackedScene.new()
    packed.pack(ui_root)
    ResourceSaver.save(packed, "res://scenes/ui/base_ui.tscn")
    print("[SCAFFOLD] Created base_ui.tscn with standard HUD/Pause hierarchy.")

## EXPERT NOTE:
## Use 'UID Health Checks': Periodically iterate through all '.tscn' and 
## '.tres' files using 'EditorInterface.get_resource_filesystem()'. 
## Compare 'ResourceLoader.get_resource_uid(path)' with the internal 
## 'uid=' strings in the file. If they mismatch, use 
## 'ResourceLoader.set_resource_uid()' to repair the reference.
## NEVER bypass the Scene Builder when modifying sensitive node trees; 
## always use 'EditorInterface.edit_node()' to ensure the editor's 
## undo/redo history is preserved.

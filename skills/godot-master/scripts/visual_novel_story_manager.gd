# godot-master/scripts/visual_novel_story_manager.gd
extends Node

## Story Manager (Expert Pattern)
## Driver for Visual Novels. Parses scripts, manages state, and directs UI.

class_name StoryManager

signal line_advanced(text: String, character: String)
signal options_presented(choices: Array)
signal scene_changed(background: String)

var script_data: Dictionary = {}
var current_index: int = 0
var flags: Dictionary = {}
var history: Array[Dictionary] = []

func load_script_from_json(path: String) -> void:
    var file = FileAccess.open(path, FileAccess.READ)
    if file:
        var json = JSON.new()
        if json.parse(file.get_as_text()) == OK:
            script_data = json.data
            current_index = 0
            _process_current_line()
        else:
            printerr("Invalid JSON script")

func advance() -> void:
    current_index += 1
    _process_current_line()

func _process_current_line() -> void:
    if not script_data.has("lines") or current_index >= script_data["lines"].size():
        return
        
    var line = script_data["lines"][current_index]
    
    # Save history state before processing
    history.append({
        "index": current_index,
        "flags": flags.duplicate(true)
    })
    
    if line.has("background"):
        scene_changed.emit(line["background"])
        
    if line.has("choices"):
        options_presented.emit(line["choices"])
    else:
        var char_name = line.get("character", "")
        var text = line.get("text", "")
        line_advanced.emit(text, char_name)

func select_choice(choice_index: int) -> void:
    var line = script_data["lines"][current_index]
    var choices = line["choices"]
    var selected = choices[choice_index]
    
    if selected.has("flag_updates"):
        for key in selected["flag_updates"]:
            flags[key] = selected["flag_updates"][key]
            
    if selected.has("jump_to"):
        _jump_to_label(selected["jump_to"])
    else:
        advance()

func _jump_to_label(label: String) -> void:
    # Simple linear search for label
    for i in range(script_data["lines"].size()):
         if script_data["lines"][i].get("label") == label:
             current_index = i
             _process_current_line()
             return

## EXPERT USAGE:
## Call load_script_from_json() with a path to a JSON file.
## Connect UI to signals to display text/choices.

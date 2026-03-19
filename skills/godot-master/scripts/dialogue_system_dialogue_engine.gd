# skills/dialogue-system/code/dialogue_engine.gd
extends Node

## Dialogue Engine Expert Pattern
## Features Graph-Based Branching and Signal-Tag Parsing.

signal narrative_event(event_id: String)
signal dialogue_finished

## BBCode Custom Tags Example: [trigger:shake]
var trigger_regex = RegEx.new()

func _ready() -> void:
    trigger_regex.compile("\\[trigger:(\\w+)\\]")

func process_dialogue_line(line_text: String) -> String:
    # 1. Parse Signal Callbacks
    # Scans text for tags like [trigger:shake_screen] and fires signals.
    var matches = trigger_regex.search_all(line_text)
    for m in matches:
        var event_name = m.get_string(1)
        narrative_event.emit(event_name)
    
    # 2. Cleanup Text
    # Returns the 'clean' text without the tags for the UI to display.
    return trigger_regex.sub(line_text, "", true)

func load_dialogue_graph(file_path: String) -> Dictionary:
    # 3. Graph Serialization
    # Professionals store dialogue in external JSON or Resources.
    if FileAccess.file_exists(file_path):
        var file = FileAccess.open(file_path, FileAccess.READ)
        return JSON.parse_string(file.get_as_text())
    return {}

## EXPERT NOTE:
## Use Godot's 'RichTextLabel' for dialogue. It natively supports 
## BBCode and custom 'RichTextEffect' objects for 'wavy' or 'shaking' text.

---
name: godot-dialogue-system
description: "Expert patterns for branching dialogue systems including dialogue graphs (Resource-based), character portraits, player choices, conditional dialogue (flags/quests), typewriter effects, localization support, and voice acting integration. Use for narrative games, RPGs, or visual novels. Trigger keywords: DialogueLine, DialogueChoice, DialogueGraph, dialogue_manager, typewriter_effect, branching_dialogue, dialogue_flags, localization, voice_acting."
---

# Dialogue System

Expert guidance for building flexible, data-driven dialogue systems.

## NEVER Do

- **NEVER hardcode dialogue in scripts** — Use Resource-based DialogueLine/DialogueGraph. Hardcoded dialogue is unmaintainable for localization.
- **NEVER forget to check choice conditions** — Displaying unavailable choices confuses players. Filter choices by `check_conditions()` before showing.
- **NEVER use string IDs without validation** — Typos in `next_line_id` cause silent failures. Add `assert(dialogues.has(line_id))` checks.
- **NEVER skip typewriter effect without player option** — Some players want instant text. Add "skip typewriter" button or setting.
- **NEVER store dialogue state in UI** — UI should only display. Store current_line/dialogue_id in DialogueManager (AutoLoad) for scene transitions.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [dialogue_engine.gd](scripts/dialogue_engine.gd)
Graph-based dialogue with BBCode signal tags. Parses [trigger:event_id] tags from text, fires signals, and loads external JSON dialogue graphs.

### [dialogue_manager.gd](scripts/dialogue_manager.gd)
Data-driven dialogue engine with branching, variable storage, and conditional choices.

---

## Dialogue Data

```gdscript
# dialogue_line.gd
class_name DialogueLine
extends Resource

@export var speaker: String
@export_multiline var text: String
@export var portrait: Texture2D
@export var choices: Array[DialogueChoice] = []
@export var conditions: Array[String] = []  # Quest flags, etc.
@export var next_line_id: String = ""
```

```gdscript
# dialogue_choice.gd
class_name DialogueChoice
extends Resource

@export var choice_text: String
@export var next_line_id: String
@export var conditions: Array[String] = []
@export var effects: Array[String] = []  # Set flags, give items
```

## Dialogue Manager

```gdscript
# dialogue_manager.gd (AutoLoad)
extends Node

signal dialogue_started
signal dialogue_ended
signal line_displayed(line: DialogueLine)
signal choice_selected(choice: DialogueChoice)

var dialogues: Dictionary = {}
var flags: Dictionary = {}

func load_dialogue(path: String) -> void:
    var data := load(path)
    dialogues[path] = data

func start_dialogue(dialogue_id: String, start_line: String = "start") -> void:
    dialogue_started.emit()
    display_line(dialogue_id, start_line)

func display_line(dialogue_id: String, line_id: String) -> void:
    var line: DialogueLine = dialogues[dialogue_id].lines[line_id]
    
    # Check conditions
    if not check_conditions(line.conditions):
        # Skip to next
        if line.next_line_id:
            display_line(dialogue_id, line.next_line_id)
        else:
            end_dialogue()
        return
    
    line_displayed.emit(line)
    
    # Auto-advance or wait for player
    if line.choices.is_empty() and line.next_line_id:
        # Wait for player to click
        await get_tree().create_timer(0.1).timeout
    elif line.choices.is_empty():
        end_dialogue()

func select_choice(dialogue_id: String, choice: DialogueChoice) -> void:
    choice_selected.emit(choice)
    
    # Apply effects
    for effect in choice.effects:
        apply_effect(effect)
    
    # Continue to next line
    if choice.next_line_id:
        display_line(dialogue_id, choice.next_line_id)
    else:
        end_dialogue()

func end_dialogue() -> void:
    dialogue_ended.emit()

func check_conditions(conditions: Array[String]) -> bool:
    for condition in conditions:
        if not flags.get(condition, false):
            return false
    return true

func apply_effect(effect: String) -> void:
    # Parse effect string, e.g., "set_flag:met_npc"
    var parts := effect.split(":")
    match parts[0]:
        "set_flag":
            flags[parts[1]] = true
        "give_item":
            # Integration with inventory
            pass
```

## Dialogue UI

```gdscript
# dialogue_ui.gd
extends Control

@onready var speaker_label := $Panel/Speaker
@onready var text_label := $Panel/Text
@onready var portrait := $Panel/Portrait
@onready var choices_container := $Panel/Choices

var current_dialogue: String
var current_line: DialogueLine

func _ready() -> void:
    DialogueManager.line_displayed.connect(_on_line_displayed)
    DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
    visible = false

func _on_line_displayed(line: DialogueLine) -> void:
    visible = true
    current_line = line
    
    speaker_label.text = line.speaker
    portrait.texture = line.portrait
    
    # Typewriter effect
    text_label.text = ""
    for char in line.text:
        text_label.text += char
        await get_tree().create_timer(0.03).timeout
    
    # Show choices
    if line.choices.is_empty():
        # Wait for input to continue
        pass
    else:
        show_choices(line.choices)

func show_choices(choices: Array[DialogueChoice]) -> void:
    # Clear existing
    for child in choices_container.get_children():
        child.queue_free()
    
    # Add choice buttons
    for choice in choices:
        if not DialogueManager.check_conditions(choice.conditions):
            continue
        
        var button := Button.new()
        button.text = choice.choice_text
        button.pressed.connect(func(): _on_choice_selected(choice))
        choices_container.add_child(button)

func _on_choice_selected(choice: DialogueChoice) -> void:
    DialogueManager.select_choice(current_dialogue, choice)

func _on_dialogue_ended() -> void:
    visible = false
```

## NPC Interaction

```gdscript
# npc.gd
extends CharacterBody2D

@export var dialogue_path: String = "res://dialogues/npc_1.tres"
@export var start_line: String = "start"

func interact() -> void:
    DialogueManager.start_dialogue(dialogue_path, start_line)
```

## Dialogue Graph (Resource)

```gdscript
# dialogue_graph.gd
class_name DialogueGraph
extends Resource

@export var lines: Dictionary = {}  # line_id → DialogueLine

func _init() -> void:
    # Example structure
    lines["start"] = create_line("Hero", "Hello!")
    lines["response"] = create_line("NPC", "Greetings, traveler!")

func create_line(speaker: String, text: String) -> DialogueLine:
    var line := DialogueLine.new()
    line.speaker = speaker
    line.text = text
    return line
```

## Localization

```gdscript
# Use Godot's built-in CSV import
# dialogue_en.csv:
# dialogue_id,speaker,text
# npc_1_start,Hero,"Hello!"
# npc_1_response,NPC,"Greetings!"

func get_localized_line(line_id: String) -> String:
    return tr(line_id)
```

## Advanced: Voice Acting

```gdscript
@onready var voice_player := $AudioStreamPlayer

func play_voice_line(line_id: String) -> void:
    var audio := load("res://voice/" + line_id + ".mp3")
    if audio:
        voice_player.stream = audio
        voice_player.play()
```

## Best Practices

1. **Resource-Based** - Store dialogues as resources
2. **Flag System** - Track player choices
3. **Typewriter Effect** - Adds polish
4. **Skip Button** - Let players skip

## Reference
- Related: `godot-signal-architecture`, `godot-save-load-systems`, `godot-ui-rich-text`


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)

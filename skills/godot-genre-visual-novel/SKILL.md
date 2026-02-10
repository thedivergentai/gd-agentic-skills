---
name: godot-genre-visual-novel
description: "Expert blueprint for visual novels (Doki Doki Literature Club, Phoenix Wright, Steins;Gate) focusing on branching narratives, dialogue systems, choice consequences, rollback mechanics, and persistent flags. Use when building story-driven, choice-based, or dating sim games. Keywords visual novel, dialogue system, branching narrative, typewriter effect, rollback, bbcode, RichTextLabel."
---

# Genre: Visual Novel

Branching narratives, meaningful choices, and quality-of-life features define visual novels.

## Core Loop
1.  **Read**: Consume narrative text and character dialogue
2.  **Decide**: Choose at key moments
3.  **Branch**: Story diverges based on choice
4.  **Consequence**: Immediate reaction or long-term flag changes
5.  **Conclude**: Reach one of multiple endings

## NEVER Do in Visual Novels

- **NEVER create illusion of choice** — If all options lead to same outcome immediately, player feels cheated. ALWAYS provide dialogue variation OR flag changes, even if plot converges later.
- **NEVER skip Auto, Skip, and Save/Load features** — These are MANDATORY in VN genre. Players replay for all routes. Missing QoL = low-quality VN.
- **NEVER display walls of unbroken text** — 6+ lines of text = intimidating. Limit to 3-4 lines per dialogue box. Break with character reactions or pauses.
- **NEVER hardcode dialogue in scripts** — Writers aren't programmers. Use JSON/CSV/custom format. Hardcoding = iteration hell for narrative changes.
- **NEVER forget rollback/history** — Player missclicks choice or wants to reread. Missing rollback = frustrating. Store state before EVERY line, use history stack.
- **NEVER ignore BBCode/rich text effects** — Plain text = boring. Use `[wave]`, `[shake]`, `[color]` in RichTextLabel for emotional beats. "I [shake]HATE[/shake] you" > "I HATE you".

---

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Text & UI | `ui-system`, `rich-text-label` | Dialogue box, bbcode effects, typewriting |
| 2. Logic | `json-parsing`, `resource-management` | Loading scripts, managing character data |
| 3. State | `godot-save-load-systems`, `dictionaries` | Flags, history, persistent data |
| 4. Audio | `audio-system` | Voice acting, background music transitions |
| 5. Polish | `godot-tweening`, `shaders` | Character transitions, background effects |

## Architecture Overview

### 1. Story Manager (The Driver)
Parses the script and directs the other systems.

```gdscript
# story_manager.gd
extends Node

var current_script: Dictionary
var current_line_index: int = 0
var flags: Dictionary = {}

func load_script(script_path: String) -> void:
    var file = FileAccess.open(script_path, FileAccess.READ)
    current_script = JSON.parse_string(file.get_as_text())
    current_line_index = 0
    display_next_line()

func display_next_line() -> void:
    if current_line_index >= current_script["lines"].size():
        return
        
    var line_data = current_script["lines"][current_line_index]
    
    if line_data.has("choice"):
        present_choices(line_data["choice"])
    else:
        CharacterManager.show_character(line_data.get("character"), line_data.get("expression"))
        DialogueUI.show_text(line_data["text"])
        current_line_index += 1
```

### 2. Dialogue UI (Typewriter Effect)
Displaying text character by character.

```gdscript
# dialogue_ui.gd
func show_text(text: String) -> void:
    rich_text_label.text = text
    rich_text_label.visible_ratio = 0.0
    
    var tween = create_tween()
    tween.tween_property(rich_text_label, "visible_ratio", 1.0, text.length() * 0.05)
```

### 3. History & Rollback
Essential VN feature. Store the state before every line.

```gdscript
var history: Array[Dictionary] = []

func save_state_to_history() -> void:
    history.append({
        "line_index": current_line_index,
        "flags": flags.duplicate(),
        "background": current_background,
        "music": current_music
    })

func rollback() -> void:
    if history.is_empty(): return
    var trusted_state = history.pop_back()
    restore_state(trusted_state)
```

## Key Mechanics Implementation

### Branching Paths (Flags)
Track decisions to influence future scenes.

```gdscript
func make_choice(choice_id: String) -> void:
    match choice_id:
        "be_nice":
            flags["relationship_alice"] += 1
            jump_to_label("alice_happy")
        "be_mean":
            flags["relationship_alice"] -= 1
            jump_to_label("alice_sad")
```

### Script Format (JSON vs Resource)
*   **JSON**: Easy to write externally, standard format.
*   **Custom Resource**: Typosafe, editable in Inspector.
*   **Text Parsers**: (e.g., Markdown-like syntax) simpler for writers.

## Common Pitfalls

1.  **Too Much Text**: Walls of text are intimidating. Break it up. **Fix**: Limit lines to 3-4 rows max.
2.  **Illusion of Choice**: Choices that lead to the same outcome immediately feel cheap. **Fix**: Use small variations in dialogue even if the main plot converges.
3.  **Missing Quality of Life**: No Skip, No Auto, No Save. **Fix**: These are mandatory features for the genre.

## Godot-Specific Tips

*   **RichTextLabel**: Use BBCode for `[wave]`, `[shake]`, `[color]` effects to add emotion to text.
*   **Resource Preloader**: Visual Novels have heavy assets (4K backgrounds). Load scenes asynchronously or use a loading screen between chapters.
*   **Dialogic**: Mentioning this plugin is important—it's the industry standard for Godot VNs. Use it if you want a full suite of tools, or build your own for lightweight needs.


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)

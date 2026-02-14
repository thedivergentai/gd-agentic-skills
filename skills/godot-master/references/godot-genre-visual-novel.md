> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Visual Novel**. Accessed via Godot Master.

# Genre: Visual Novel

Expert blueprint for building narrative-heavy Visual Novels and dating simulators. Focuses on branching dialogue trees, persistent story flags, typewriter-style text reveal, and mandatory quality-of-life features like Rollback and Auto-skip.

## Available Scripts

### [story_manager.gd](../scripts/godot-genre-visual-novel_story_manager.gd)
The core engine for the Visual Novel. Parses JSON-based dialogue scripts, manages branch points based on player flags, and directs character/background transitions.

### [dialogue_ui.gd](../scripts/godot-genre-visual-novel_dialogue_ui.gd)
Manages the presentation layer. Implements character-by-character typewriter reveal (using Tweens), BBCode parsing for emphasis, and choice-window generation.

### [vn_rollback_manager.gd](../scripts/godot-genre-visual-novel_vn_rollback_manager.gd)
Essential genre-specific helper. Maintains a history stack of the game state (flags, background, line index) allowing the player to scroll back through dialogue history at any time.


## NEVER Do

- **NEVER create the "Illusion of Choice" exclusively** — If every choice in the game leads to the exact same dialogue line immediately after, players will feel their agency is ignored. Even if the plot converges later, always provide immediate dialogue variations or flag changes.
- **NEVER skip QoL features like Auto, Fast-Forward, and Backlog** — Visual Novels are often replayed to see all routes. Forcing a player to manually click through a 2-hour script they've already seen is a failure of UX.
- **NEVER hardcode dialogue text inside GDScripts** — Narrative scripts should be stored in external files (JSON, CSV, or custom text formats). Hardcoding makes translation and editing for non-programmers impossible.
- **NEVER display "Walls of Text"** — A dialogue box filled with 10 lines of tiny text is intimidating. Follow the "Rule of Three": limit your dialogue boxes to 3 or 4 lines of text at maximum.
- **NEVER ignore the Rollback mechanic** — Players often miss-click or want to reread a previous line. A VN without a history/log or rollback feature is considered unprofessional.
- **NEVER use plain text for emotional beats** — Use Godot's `RichTextLabel` BBCode features. Instead of writing "I am very angry", use `[shake rate=20 level=10]I am very angry![/shake]` to add visual weight to the dialogue.

---

## Branching Logic (Flags)
Use a global `flags` Dictionary to track player decisions:
```gdscript
# On choice made
flags["romance_points_alice"] += 1
# Later in the script
if flags["romance_points_alice"] > 5:
    jump_to("Alice_Date_Scene")
```

## Typewriter Effect
Use a `Tween` to animate the `visible_characters` or `visible_ratio` property of a `RichTextLabel`.
- **Pro Tip**: Use the `[wait]` or `[p]` tag in your custom parser to pause the typewriter for dramatic effect at commas or periods.

## Character Sprites and Backgrounds
- Use `TextureRect` nodes with `CanvasLayer` for UI.
- Implement cross-fades using the `modulate` property and `Tween` for seamless transitions between expressions or scenes.

## The Script Parser
Common patterns for VN scripts:
1. **JSON**: Structured but can be tedious for writers to type brackets.
2. **Tab-Separated / CSV**: Easy for Excel users.
3. **Dialogue Plugins**: Plugins like **Dialogic** for Godot provide high-level editors that generate these files for you.

## Reference
- [Godot Docs: RichTextLabel BBCode](https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html)
- [Ren'Py (External Reference for Best Practices)](https://www.renpy.org/doc/html/)

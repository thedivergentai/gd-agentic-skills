> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Dialogue Systems**. Accessed via Godot Master.

# Dialogue System

Expert guidance for building flexible, data-driven dialogue systems with branching narratives, choice conditions, and UI polish.

## Available Scripts

### [dialogue_engine.gd](../scripts/dialogue_system_dialogue_engine.gd)
Graph-based dialogue engine that parses signal tags (e.g., `[trigger:event]`) and handles external JSON dialogue graphs for complex narratives.

### [dialogue_manager.gd](../scripts/dialogue_system_dialogue_manager.gd)
Lightweight dialogue state manager tracking variables, character flags, and conditional choice filtering.


## NEVER Do

- **NEVER hardcode dialogue strings in scripts** — Use Resource-based `.tres` or JSON files. Hardcoded text makes localization and proofreading impossible.
- **NEVER display choices without checking conditions** — Irrelevant or locked choices clutter the UI. Always run a `check_conditions()` pass before rendering buttons.
- **NEVER use string IDs without validation** — Typoing a "next_line_id" creates dead ends. Use assertions to verify IDs exist in your dialogue dictionary.
- **NEVER force a typewriter effect without a skip option** — Accessibility and user preference vary; always provide a way to instantly display the full text.
- **NEVER store narrative state inside UI components** — UI should be purely reactive. Store "current line" and "active speaker" in a central `DialogueManager` AutoLoad.

---

## Data Structure: The Dialogue Grid
Dialogue is best organized into `DialogueLine` resources containing:
- **Speaker**: String ID or Name.
- **Text**: The actual content (BBCode supported).
- **Portrait**: Optional texture for character facial expressions.
- **Choices**: Array of `DialogueChoice` resources with their own conditions and jump markers.

## Typewriter Effect Implementation
Iterate through the string, appending characters to a `RichTextLabel` with a small delay. Use a `Timer` or `await get_tree().create_timer(delay).timeout`.

## Conditional Branching
Use a simple global flag dictionary. When a choice is made, it can set a flag (e.g., `set_flag:npc_met`). Future dialogue lines can then check these flags (e.g., `has_flag:npc_met`) to alter the flow of conversation.

## Localization Support
Leverage Godot's built-in `tr()` function for all dialogue text. Use unique keys for your dialogue lines (e.g., `NPC1_GREETING`) and maintain a CSV/JSON translation table.

## Voice Acting Integration
Sync dialogue lines with specific `.mp3` or `.ogg` files. Trigger the audio play event concurrently with the start of the typewriter effect.

## Reference
- [Godot Docs: Internationalization](https://docs.godotengine.org/en/stable/tutorials/i18n/internationalizing_games.html)
- [Godot Docs: BBCode in RichTextLabel](https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html)

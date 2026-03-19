---
name: godot-ui-rich-text
description: "Expert blueprint for RichTextLabel with BBCode formatting (bold, italic, colors, images, clickable links) and custom effects. Covers meta tags, RichTextEffect shaders, and dynamic content. Use when implementing dialogue systems OR formatted text. Keywords RichTextLabel, BBCode, [b], [color], [url], meta_clicked, RichTextEffect, dialogue."
---

# Rich Text & BBCode

BBCode tags, meta clickable links, and RichTextEffect shaders define formatted text systems.

### [rich_text_rainbow_effect.gd](../scripts/ui_rich_text_rich_text_rainbow_effect.gd)
Expert custom `RichTextEffect` that rotates colors over time.

### [rich_text_glitch_effect.gd](../scripts/ui_rich_text_rich_text_glitch_effect.gd)
Professional horror-style glitch effects with spatial jitter and alpha flickering.

### [rich_text_typewriter_controller.gd](../scripts/ui_rich_text_rich_text_typewriter_controller.gd)
Dialogue manager that parses sequential event tags (`[pause]`, `[speed]`) during animations.

### [rich_text_meta_dispatch.gd](../scripts/ui_rich_text_rich_text_meta_dispatch.gd)
Advanced handling for multi-prefix URLs in meta-clicks (items, quests, NPCs).

### [rich_text_image_scaler.gd](../scripts/ui_rich_text_rich_text_image_scaler.gd)
Utility to dynamically scale `[img]` tags to match runtime font sizes.

### [rich_text_hover_reactive.gd](../scripts/ui_rich_text_rich_text_hover_reactive.gd)
Signals and logic for making text spans reactive to mouse hover (SFX/Cursors).

### [rich_text_bbcode_sanitizer.gd](../scripts/ui_rich_text_rich_text_bbcode_sanitizer.gd)
Security utility to prevent BBCode injection in public chat interfaces.

### [rich_text_gradient_generator.gd](../scripts/ui_rich_text_rich_text_gradient_generator.gd)
Generator for multi-stop linear gradients using granular character-level tagging.

### [rich_text_auto_scroller.gd](../scripts/ui_rich_text_rich_text_auto_scroller.gd)
Smooth vertical auto-scrolling logic for credits, news feeds, and logs.

### [rich_text_syntax_highlighter.gd](../scripts/ui_rich_text_rich_text_syntax_highlighter.gd)
Simple regex-based syntax highlighting pattern for code blocks in UI.

## NEVER Do (Expert UI Rules)

### Formatting & Rendering
- **NEVER use complex BBCode in tight loops** — Parsing a 10,000 character string with 500 tags every frame will tank performance. Cache your formatted strings.
- **NEVER forget to register Custom Effects** — Writing the script isn't enough. You MUST add the instance to `RichTextLabel.custom_effects` list via Inspector or `install_effect()`.
- **NEVER use absolute pixel sizes in [img]** — `[img width=128]` fails on higher resolutions. Use `rich_text_image_scaler.gd` to sync with line height.

### Click & Hover UX
- **NEVER use [url] without visual feedback** — If the text doesn't change color on hover or the cursor doesn't change, players won't know it's clickable. Use `rich_text_hover_reactive.gd`.
- **NEVER perform heavy logic inside `meta_clicked`** — This signal is on the Main Thread. Use it to emit a command and handle processing asynchronously if needed.

### Dialogue & Narrative
- **NEVER use `visible_ratio` for pausing typewriter** — `visible_ratio` is unreliable for per-character logic. Use `visible_characters` and explicit character indexing (`rich_text_typewriter_controller.gd`).
- **NEVER allow unfiltered user input in Chat Labels** — A user could type `[img]huge_image_path[/img]` or `[color=transparent]` to break your UI. ALWAYS use `rich_text_bbcode_sanitizer.gd`.

---

```gdscript
$RichTextLabel.bbcode_enabled = true
$RichTextLabel.text = "[b]Bold[/b] and [i]italic[/i] text"
```

## Common Tags

```bbcode
[b]Bold[/b]
[i]Italic[/i]
[u]Underline[/u]
[color=red]Red text[/color]
[color=#00FF00]Green hex[/color]
[center]Centered[/center]
[img]res://icon.png[/img]
[url=data]Clickable link[/url]
```

## Handle Link Clicks

```gdscript
func _ready() -> void:
    $RichTextLabel.meta_clicked.connect(_on_meta_clicked)

func _on_meta_clicked(meta: Variant) -> void:
    print("Clicked: ", meta)
```

## Reference
- [Godot Docs: BBCode in RichTextLabel](https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html)


### Related
- Master Skill: [godot-master](../SKILL.md)

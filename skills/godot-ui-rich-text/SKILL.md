---
name: godot-ui-rich-text
description: "Expert blueprint for RichTextLabel with BBCode formatting (bold, italic, colors, images, clickable links) and custom effects. Covers meta tags, RichTextEffect shaders, and dynamic content. Use when implementing dialogue systems OR formatted text. Keywords RichTextLabel, BBCode, [b], [color], [url], meta_clicked, RichTextEffect, dialogue."
---

# Rich Text & BBCode

BBCode tags, meta clickable links, and RichTextEffect shaders define formatted text systems.

## Available Scripts

### [custom_bbcode_effect.gd](scripts/custom_bbcode_effect.gd)
Expert custom RichTextEffect examples (wave, rainbow, shake, typewriter).

### [rich_text_animator.gd](scripts/rich_text_animator.gd)
Typewriter effect for BBCode text with support for custom event tags and pausing.

## NEVER Do in Rich Text

- **NEVER forget bbcode_enabled** — `text = "[b]bold[/b]"` without `bbcode_enabled = true`? Literal brackets shown. ALWAYS enable BBCode first.
- **NEVER use [img] without res:// path** — `[img]icon.png[/img]` with relative path? Image not found. Use full resource path: `[img]res://assets/icon.png[/img]`.
- **NEVER skip newline preservation** — `text = "Line1\nLine2"` renders as "Line1Line2"? BBCode eats newlines. Use `[br]` OR `\n` with proper escaping.
- **NEVER use [url] without meta_clicked** — `[url=shop]Buy[/url]` without signal connection? Click does nothing. MUST connect `meta_clicked` signal.
- **NEVER nest same tag types** — `[b][b]text[/b][/b]`? Undefined behavior. Nest different tags: `[b][i]text[/i][/b]`.
- **NEVER use [color] with invalid formats** — `[color=redd]text[/color]` typo? Falls back to white OR black. Use named colors OR hex: `[color=#FF0000]` for validation.

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
- Master Skill: [godot-master](../godot-master/SKILL.md)

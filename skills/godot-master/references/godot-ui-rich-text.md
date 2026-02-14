> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Rich Text & BBCode**. Accessed via Godot Master.

# Rich Text & BBCode

Expert blueprint for `RichTextLabel` implementation. Focuses on advanced BBCode formatting, dynamic text effects, and interactive metadata handling for dialogue and UI systems.

## Available Scripts

### [custom_bbcode_effect.gd](../scripts/godot-ui-rich-text_custom_bbcode_effect.gd)
Collection of custom `RichTextEffect` resources. Includes "Ghost", "Rainbow", "Matrix", and "Pulse" effects that can be applied to text within brackets (e.g., `[ghost]text[/ghost]`).

### [rich_text_animator.gd](../scripts/godot-ui-rich-text_rich_text_animator.gd)
A powerful typewriter engine for `RichTextLabel`. Supports sequential reveal, per-character delay, and "wait" tags. Ideal for RPG dialogues and narrative-heavy games.


## NEVER Do

- **NEVER attempt to render BBCode without enabling it** — If `bbcode_enabled` is false, your text will literally show the brackets (e.g., "[b]Bold[/b]"). Always set this property to `true` before assigning formatted strings.
- **NEVER use relative paths for images in BBCode** — The `[img]` tag requires an absolute resource path (e.g., `res://icons/sword.png`). Simple filenames will fail to resolve.
- **NEVER expect standard `\n` to work consistently in BBCode** — Depending on the layout, raw newlines may be stripped or mishandled. Use the `[br]` tag or ensure proper escaping when injecting strings via code.
- **NEVER use the `[url]` tag without a `meta_clicked` signal handler** — BBCode links are not "web links" by default; they are just metadata. You MUST connect the `meta_clicked` signal to a script that tells the OS to open the link or triggers a game event.
- **NEVER nest identical tag types** — Nesting like `[b][b]text[/b][/b]` can lead to unpredictable rendering or parsing errors. Nest different tags (e.g., `[b][i]text[/i][/b]`) instead.
- **NEVER hardcode hex colors for dynamic text** — Swapping themes is impossible if your text colors are hardcoded inside the BBCode strings. Use named colors (e.g., `[color=red]`) or inject theme colors dynamically at runtime.

---

## Interactive Metadata (`[url]`)
BBCode metadata allows for sophisticated click-interactions:
1. Format: `[url={"action": "buy", "id": 42}]Click Me[/url]`
2. Signal: `meta_clicked(meta: Variant)`
3. Handler: Parse the dictionary in the `meta` variable and trigger the corresponding game logic (e.g., opening a shop menu).

## Custom RichTextEffects
Create shaders or scripts that inherit from `RichTextEffect`.
- **Register them**: `richtextlabel.install_effect(PulseEffect.new())`
- **Use them**: `[pulse freq=5.0]This text is pulsing![/pulse]`

## Dynamic Dialogue Systems
Use `rich_text_animator.gd` to create narrative text:
- Slow down text speed for dramatic effect.
- Pause at commas or periods.
- Trigger signal events (e.g., `_on_text_event("camera_shake")`) directly from the BBCode string.

## Reference
- [Godot Docs: BBCode in RichTextLabel](https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html)
- [Godot Docs: RichTextEffect](https://docs.godotengine.org/en/stable/classes/class_richtexteffect.html)

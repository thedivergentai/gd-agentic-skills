---
name: godot-ui-theming
description: "Expert blueprint for UI themes using Theme resources, StyleBoxes, custom fonts, and theme overrides for consistent visual styling. Covers StyleBoxFlat/Texture, theme inheritance, dynamic theme switching, and font variations. Use when implementing consistent UI styling OR supporting multiple themes. Keywords Theme, StyleBox, StyleBoxFlat, add_theme_override, font, theme inheritance, dark mode."
---

# UI Theming

Theme resources, StyleBox styling, font management, and override system define consistent UI visual identity.

## Available Scripts

### [global_theme_manager.gd](scripts/global_theme_manager.gd)
Expert theme manager with dynamic switching, theme variants, and fallback handling.

### [ui_scale_manager.gd](scripts/ui_scale_manager.gd)
Runtime theme switching and DPI/Resolution scale management.

## NEVER Do in UI Theming

- **NEVER create StyleBox in _ready() for many nodes** — 100 buttons × `StyleBoxFlat.new()` in `_ready()`? 100 duplicate objects. Create ONCE in theme resource, reuse via inheritance.
- **NEVER forget theme inheritance** — Child Control with custom theme? Parent theme ignored. Set `theme` on root Control, children auto-inherit unless overriding.
- **NEVER hardcode colors in StyleBox** — `style.bg_color = Color(0.2, 0.3, 0.5)`? Unmaintainable. Define colors in theme, reference via `theme.get_color("primary", "Button")`.
- **NEVER use add_theme_override for global styles** — Call `add_theme_*_override()` on 50 nodes? Brittle. Define in Theme resource for automatic propagation.
- **NEVER skip corner_radius_all shortcut** — Set 4 corner radii individually? Verbose. Use `corner_radius_all = 5` for uniform corners (StyleBoxFlat only).
- **NEVER modify theme during rendering** — Change theme in `_draw()` OR `_process()`? Constant re-layout = performance tank. Load themes at initialization OR on user action only.

---

1. Project Settings → **GUI → Theme**
2. Create new Theme resource
3. Assign to root Control node
4. All children inherit theme

## StyleBox Pattern

```gdscript
# Create StyleBoxFlat for buttons
var style := StyleBoxFlat.new()
style.bg_color = Color.DARK_BLUE
style.corner_radius_top_left = 5
style.corner_radius_top_right = 5
style.corner_radius_bottom_left = 5
style.corner_radius_bottom_right = 5

# Apply to button
$Button.add_theme_stylebox_override("normal", style)
```

## Font Loading

```gdscript
# Load custom font
var font := load("res://fonts/my_font.ttf")
$Label.add_theme_font_override("font", font)
$Label.add_theme_font_size_override("font_size", 24)
```

## Reference
- [Godot Docs: GUI Theming](https://docs.godotengine.org/en/stable/tutorials/ui/gui_skinning.html)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)

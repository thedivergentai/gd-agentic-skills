---
name: godot-ui-theming
description: "Expert blueprint for UI themes using Theme resources, StyleBoxes, custom fonts, and theme overrides for consistent visual styling. Covers StyleBoxFlat/Texture, theme inheritance, dynamic theme switching, and font variations. Use when implementing consistent UI styling OR supporting multiple themes. Keywords Theme, StyleBox, StyleBoxFlat, add_theme_override, font, theme inheritance, dark mode."
---

# UI Theming

Theme resources, StyleBox styling, font management, and override system define consistent UI visual identity.

## Available Scripts

### [global_theme_manager.gd](../scripts/ui_theming_global_theme_manager.gd)
Expert theme manager with dynamic switching, theme variants, and fallback handling.

### [ui_scale_manager.gd](../scripts/ui_theming_ui_scale_manager.gd)
Runtime theme switching and DPI/Resolution scale management.

### [theme_swapper.gd](../scripts/ui_theming_theme_swapper.gd)
Dynamic Dark/Light mode implementation using cascading theme root propagation.

### [danger_button_assignment.gd](../scripts/ui_theming_danger_button_assignment.gd)
Expert use of `theme_type_variation` for semantic UI styling without scene duplication.

### [dynamic_stylebox_color.gd](../scripts/ui_theming_dynamic_stylebox_color.gd)
Safe runtime StyleBox modification. Demonstrates the critical `duplicate()` pattern for isolated overrides.

### [procedural_theme_safe.gd](../scripts/ui_theming_procedural_theme_safe.gd)
Reliable theming for generated UI elements using `NOTIFICATION_THEME_CHANGED`.

### [custom_chart_drawing.gd](../scripts/ui_theming_custom_chart_drawing.gd)
Pattern for reading active Theme properties (colors, fonts) in custom `_draw()` logic.

### [theme_isolation.gd](../scripts/ui_theming_theme_isolation.gd)
Ensuring HUD consistency by isolating nodes from parent themes and referencing Project Defaults.

### [pulsating_ui_theme.gd](../scripts/ui_theming_pulsating_ui_theme.gd)
Animating UI styles via Tweens. Targets StyleBox properties directly after duplication.

### [crisp_ui_scaler.gd](../scripts/ui_theming_crisp_ui_scaler.gd)
High-quality resolution-independent scaling using `content_scale_factor` to maintain font crispness.

### [memory_safe_custom_drawing.gd](../scripts/ui_theming_memory_safe_custom_drawing.gd)
Fixing the "disappearing stylebox" bug by caching resources at the class level for the RenderingServer.

### [rtl_theme_mirroring.gd](../scripts/ui_theming_rtl_theme_mirroring.gd)
Bi-directional (RTL/LTR) UI support. Swaps theme variants dynamically based on layout direction.

## NEVER Do in UI Theming

- **NEVER create StyleBox in `_ready()` for many nodes** — Instantiating `StyleBoxFlat.new()` 100 times creates 100 unique objects. Use a Theme resource for shared heritage.
- **NEVER forget theme inheritance** — Parent themes are ignored if a child has its own theme. Apply themes at the root and use `theme_type_variation` for specific overrides.
- **NEVER hardcode colors in StyleBox** — Use `theme.get_color()` to maintain a single source of truth for your palette.
- **NEVER use `add_theme_override` for global styles** — This is brittle. Define styles in a Theme resource for automatic propagation across the project.
- **NEVER modify theme resources during `_draw()` OR `_process()`** — Frequent layout recalculations will severely degrade performance.
- **NEVER assign `StyleBoxEmpty` to focus styles without a fallback** — This invisibly breaks controller/keyboard navigation [1]. Always provide a visible alternative (e.g. scale change).
- **NEVER use standard `set()` for theme properties** — Calling `node.set("font_color", red)` fails. You MUST use the dedicated `add_theme_color_override()` API [3].
- **NEVER use `expand_margin_*` to increase clickable area** — It only expands the VISUAL bounds. Use `content_margin_*` on the StyleBox or adjust the Control's size to ensure input works [5].
- **NEVER define StyleBoxes as local variables inside `_draw()`** — They will be garbage collected before the RenderingServer can finish drawing them [7]. Store at class level.
- **NEVER duplicate scenes/themes just to change one color** — Use `theme_type_variation` to create lightweight derived styles (e.g. "DangerButton") within the same Theme [8].
- **NEVER skip `corner_radius_all` shortcut** — It's a useful shorthand for uniform rounding in `StyleBoxFlat`.

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
- Master Skill: [godot-master](../SKILL.md)

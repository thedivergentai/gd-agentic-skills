---
name: godot-ui-containers
description: "Expert blueprint for responsive UI layouts using Container nodes (HBoxContainer, VBoxContainer, GridContainer, MarginContainer, ScrollContainer). Covers size flags, anchors, split containers, and dynamic layouts. Use when building adaptive interfaces OR implementing responsive menus. Keywords Container, HBoxContainer, VBoxContainer, GridContainer, size_flags, EXPAND_FILL, anchors, responsive."
---

# UI Containers

Container auto-layout, size flags, anchors, and split ratios define responsive UI systems.

## Available Scripts

### [responsive_layout_builder.gd](scripts/responsive_layout_builder.gd)
Expert container builder with breakpoint-based responsive layouts.

### [responsive_grid.gd](scripts/responsive_grid.gd)
Auto-adjusting GridContainer that changes column count based on available width. Essential for responsive inventory screens and resizing windows.

## NEVER Do in UI Containers

- **NEVER set child position/size manually in Container** — `child.position = Vector2(10, 10)` inside HBoxContainer? Container overrides it on layout. Use `custom_minimum_size` OR margins instead.
- **NEVER forget size_flags for expansion** — Child in VBoxContainer doesn't expand? Default is SHRINK. Set `size_flags_vertical = SIZE_EXPAND_FILL` for fill behavior.
- **NEVER use GridContainer without columns** — `GridContainer` with default `columns = 1`? Vertical list, wrong layout. ALWAYS set `columns` property to grid width.
- **NEVER nest too many containers** — 10 levels of HBox in VBox in HBox? Re-layout overhead + hard to debug. Flatten OR use Control with custom layout.
- **NEVER skip separation override** — Default 4px separation? Cramped UI. Override with `add_theme_constant_override("separation", value)` for breathing room.
- **NEVER use ScrollContainer without minimum size** — ScrollContainer with no `custom_minimum_size`? Expands infinitely, no scrolling. Set minimum OR use anchors.

---

```gdscript
# VBoxContainer example
# Automatically stacks children vertically
# Children:
#   Button ("Play")
#   Button ("Settings")
#   Button ("Quit")

# Set separation between items
$VBoxContainer.add_theme_constant_override("separation", 10)
```

## Responsive Layout

```gdscript
# Use anchors and size flags
func _ready() -> void:
    # Expand to fill parent
    $MarginContainer.set_anchors_preset(Control.PRESET_FULL_RECT)
    
    # Add margins
    $MarginContainer.add_theme_constant_override("margin_left", 20)
    $MarginContainer.add_theme_constant_override("margin_right", 20)
```

## SizeFlags

```gdscript
# Control how children expand in containers
button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
```

## Reference
- [Godot Docs: GUI Containers](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)

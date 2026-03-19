---
name: godot-ui-containers
description: "Expert blueprint for responsive UI layouts using Container nodes (HBoxContainer, VBoxContainer, GridContainer, MarginContainer, ScrollContainer). Covers size flags, anchors, split containers, and dynamic layouts. Use when building adaptive interfaces OR implementing responsive menus. Keywords Container, HBoxContainer, VBoxContainer, GridContainer, size_flags, EXPAND_FILL, anchors, responsive."
---

# UI Containers

Container auto-layout, size flags, anchors, and split ratios define responsive UI systems.

## Available Scripts

### [responsive_layout_builder.gd](../scripts/ui_containers_responsive_layout_builder.gd)
Expert container builder with breakpoint-based responsive layouts.

### [responsive_grid.gd](../scripts/ui_containers_responsive_grid.gd)
Auto-adjusting GridContainer that changes column count based on available width.

### [responsive_inventory_grid.gd](../scripts/ui_containers_responsive_inventory_grid.gd)
Expert logic for dynamic Grid columns based on available width and item minimum size.

### [terminal_autoscroll.gd](../scripts/ui_containers_terminal_autoscroll.gd)
Safe ScrollContainer management. Handles the common "one-frame delay" bug when adding logs or chat.

### [viewport_3d_preview.gd](../scripts/ui_containers_viewport_3d_preview.gd)
High-performance 3D-in-UI setup. Uses `stretch_shrink` and `transparent_bg` for character previews.

### [dynamic_tab_manager.gd](../scripts/ui_containers_dynamic_tab_manager.gd)
Pattern for dynamic tab spawning, custom titles, and tab closing logic.

### [responsive_tag_cloud.gd](../scripts/ui_containers_responsive_tag_cloud.gd)
Wrapping item lists using `HFlowContainer`, essential for tag clouds and responsive menus.

### [performance_anchor_layout.gd](../scripts/ui_containers_performance_anchor_layout.gd)
Optimization architecture. Replaces deep container nesting with lightweight Anchor and Offset logic.

### [custom_radial_container.gd](../scripts/ui_containers_custom_radial_container.gd)
Expert custom container logic implementing a radial/circle layout via `NOTIFICATION_SORT_CHILDREN`.

### [animated_container_shuffle.gd](../scripts/ui_containers_animated_container_shuffle.gd)
Dynamic sibling reordering and animation logic for interactive UI lists.

### [aspect_ratio_mini_map.gd](../scripts/ui_containers_aspect_ratio_mini_map.gd)
Enforcing strict aspect ratios (e.g. 1:1, 16:9) across fluid window resizes using `AspectRatioContainer`.

### [container_size_flags_pro.gd](../scripts/ui_containers_container_size_flags_pro.gd)
Advanced sizing logic using `SIZE_EXPAND_FILL` and `stretch_ratio` for weighted layouts.

## NEVER Do in UI Containers

- **NEVER manually set child `position` or `size` in a Container** — Containers override child transforms during `queue_sort()`. Use `custom_minimum_size` or `size_flags` instead [1].
- **NEVER forget `size_flags` for expansion** — Default is `SIZE_SHRINK_BEGIN`. Children will stay tiny unless you set `SIZE_EXPAND_FILL` for responsive containers.
- **NEVER use `GridContainer` without setting `columns`** — Default is 1, creating a simple vertical list. For responsive wrapping, use `HFlowContainer` instead [8].
- **NEVER nest containers too deeply (10+ levels)** — Heavy nesting causes layout recalculation spikes. Replace intermediate containers with Anchor Layouts for static padding [16].
- **NEVER skip separation overrides** — Default theme separation is often too tight. Use `add_theme_constant_override("separation", value)` for professional breathing room.
- **NEVER use `ScrollContainer` without a minimum size** — Without it, the container may collapse to zero or expand infinitely, breaking the scroll mechanism.
- **NEVER scroll to a new child on the same frame it was added** — The layout hasn't updated yet. You MUST `await get_tree().process_frame` before setting `scroll_vertical` [5].
- **NEVER scale a `SubViewportContainer` to change its size** — This distorts the rendered contents. Adjust margins or use `stretch` and `stretch_shrink` properties instead [2].
- **NEVER leave `mouse_filter` on default for layered Viewports** — Input events might not reach children. Use `MOUSE_FILTER_PASS` or `STOP` to ensure events drill down [6].
- **NEVER use `GridContainer` for responsive wrapping** — Use `HFlowContainer` if you want items to wrap based on width. GridContainer enforces a strict column count [7].
- **NEVER animate `position` directly inside a container** — Use `Tween` on `custom_minimum_size` to smoothly "push" siblings during transitions [1].

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
- Master Skill: [godot-master](../SKILL.md)

> [!NOTE]
> **Resource Context**: This module provides expert patterns for **UI Containers**. Accessed via Godot Master.

# UI Containers

Expert blueprint for responsive UI layouts using Godot's container nodes. Focuses on auto-layout, size flags, and adaptive scaling across different screen aspect ratios.

## Available Scripts

### [responsive_layout_builder.gd](../scripts/ui_containers_responsive_layout_builder.gd)
Advanced helper for building complex layouts at runtime. Implements breakpoint-based logic (e.g., swapping from horizontal to vertical layouts) to ensure menus look correct on both mobile/portrait and desktop/landscape.

### [responsive_grid.gd](../scripts/ui_containers_responsive_grid.gd)
A specialized wrapper for `GridContainer`. Automatically adjusts the number of columns based on the current viewport width. Mandatory for responsive inventory grids and shop interfaces.


## NEVER Do

- **NEVER set a child's position or size manually within a Container** — The entire purpose of nodes like `VBoxContainer` is to take control of their children's transforms. Manually setting `position` will be instantly overridden by the container. Use **Margins** or **Padding** instead.
- **NEVER forget to configure Size Flags for scaling** — If a child node doesn't expand to fill its parent container, it's usually because the `Size Flag` is set to "Shrink". For filling behavior, set BOTH horizontal and vertical flags to **Expand & Fill**.
- **NEVER use a `GridContainer` without defining columns** — A `GridContainer` defaults to 1 column, effectively acting like a vertical list. Always set the `columns` property to your desired grid width.
- **NEVER create "Container Hell" (Deep Nesting)** — Nesting 5+ levels of containers purely for positioning makes the scene hard to read and performance-heavy. Use **Anchors** or custom `Control` layouts to flatten the hierarchy where possible.
- **NEVER rely on default Theme Separation** — The default 4px separation often results in "cramped" designs. Use `add_theme_constant_override("separation", value)` to add breathing room and visual hierarchy to your lists.
- **NEVER use `ScrollContainer` without a minimum size** — A `ScrollContainer` with no minimum size or anchor configuration will shrink to zero or expand infinitely, breaking the scroll functionality. Always define a visible region.

---

## Core Containers
- **HBox/VBox**: The fundamental building blocks. Stack children horizontally or vertically.
- **MarginContainer**: Adds internal padding around all its children. Perfect for keeping UI away from screen edges.
- **CenterContainer**: Keeps one or more children perfectly centered within the parent.
- **GridContainer**: Organizes items into a formal grid. Use for inventories and character select screens.
- **TabContainer**: Manages multiple panels (pages) with a tab bar for navigation.

## Size Flag Cheat Sheet
- **Shrink Start/Center/End**: The node stays at its minimum size at the specified position.
- **Fill**: The node expands to occupy all available space given by its parent.
- **Expand**: The node "paints" its share of any extra space left over in the container.
- **Expand & Fill**: The gold standard for responsive UI elements that should grow with the window.

## Adaptive Breakpoints
Use `responsive_layout_builder.gd` to detect when the screen is too narrow (e.g., `< 600px`).
1. If Narrow: Switch `HBoxContainer` orientation to vertical.
2. If Wide: Reflow the layout back to horizontal.
This ensures your game UI works seamlessly on both Steam Deck (16:10) and ultrawide monitors (21:9).

## Reference
- [Godot Docs: Container Nodes](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html)
- [Godot Docs: Size Flags](https://docs.godotengine.org/en/stable/tutorials/ui/size_flags.html)

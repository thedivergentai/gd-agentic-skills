# Theme: Easter & Seasonal Aesthetics

> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Seasonal Theming**. Accessed via Godot Master.

## Architectural Thinking: Non-Destructive Theming

A Master implementation of seasonal themes avoids permanent file modification. Instead, it uses **Runtime Injections** and **Material Swaps** to ensure the game can revert to "Default" state instantly.

### Core Strategies
- **Palette Injection**: Recursive overriding of control styles using duplicated StyleBoxes.
- **Material Swapping**: Swapping PBR materials on MeshInstances without affecting geometry.
- **Physics Flair**: Adding temporary components (e.g., Wobble) to generic objects to change their "perceived" identity.

## Expert Code Patterns

### 1. Safe StyleBox Duplication
NEVER modify a `StyleBox` from a theme directly; it is a shared resource. Always `duplicate()` to isolate changes.

```gdscript
# theme_easter_palette_override.gd
# Safety first: Avoid corrupting the global Project Theme
if existing is StyleBoxFlat:
    new_style = existing.duplicate()
    new_style.bg_color = color
    control.add_theme_stylebox_override(theme_item, new_style)
```

### 2. Seasonal Component Injection
Use components that add logic (e.g., egg wobbling) to standard RigidBodies during the season.

```gdscript
# theme_easter_bouncy_egg_component.gd
# Add a center-of-mass offset to make any sphere behave like an egg.
rigid_body.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
rigid_body.center_of_mass = Vector3(0, -0.2, 0)
```

## Aesthetic Guidelines (Easter)

| Element | Expert Choice | Fallback |
| :--- | :--- | :--- |
| **Pink** | `#FFC1CC` (Pastel) | Red |
| **Yellow** | `#FFFFE0` (Lemon) | Orange |
| **Corners** | `radius > 12px` | `0px` |
| **Motion** | Squash & Stretch | Rigid |

## Veteran-Only Gotchas (Never List)

- **NEVER Modify Global Resources**: Always `duplicate()` a StyleBox before changing its properties at runtime, or you will affect every node in the game using that style.
- **Avoid deeply nested node modification**: Recursion is powerful but can be slow on complex UIs. Cache target nodes if possible.
- **Don't Hardcode**: Use the `SeasonalMaterialSwapper` so you can turn *off* Easter after April.
- **Juice**: Easter is high-energy. Things should pop, bounce, and wiggle.

## Registry

- **Expert Component**: [palette_override.gd](../scripts/theme_easter_palette_override.gd)
- **Expert Component**: [bouncy_egg_component.gd](../scripts/theme_easter_bouncy_egg_component.gd)
- **Expert Component**: [seasonal_material_swapper.gd](../scripts/theme_easter_seasonal_material_swapper.gd)

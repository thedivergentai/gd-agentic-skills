---
name: godot-theme-easter
description: Use when applying a specific Easter holiday theme (Eggs, Bunnies, Pastels) to a game.
---

# Easter Theme (Aesthetics & Juice)

## Overview
This skill provides the assets and logic to "Easter-fy" a game. It focuses on the **Classic Easter** aesthetic: bright pastels, bouncy animations, and egg/bunny iconography.

## Core Components

### 1. Easter Palette Override (`easter_palette_override.gd`)
A runtime theme injector.
- **Behavior**: Iterates through UI nodes and applies a pre-defined "Easter" color palette (Pink, Cyan, Yellow, Mint).
- **Use for**: Instantly theming a menu or HUD without manually editing 50 `StyleBoxFlat` resources.

### 2. Bouncy Egg Component (`bouncy_egg_component.gd`)
A physics/tween controller for "Egg-like" behavior.
- **Behavior**:
    -   **Physics**: Apply a center-of-mass offset so it wobbles.
    -   **Visual**: Apply a squash-and-stretch tween on impact.
- **Use for**: Making collectibles feel like eggs rather than generic spheres.

### 3. Seasonal Material Swapper (`seasonal_material_swapper.gd`)
A manager for switching assets based on the season.
- **Behavior**: Swaps `MeshInstance3D` materials from a "Default" set to an "Easter" set (e.g., Crate -> Gift Box).
- **Use for**: Non-destructive seasonal updates.

## Visual Guidelines
- **Colors**:
    -   Pink: `#FFC1CC`
    -   Cyan: `#E0FFFF`
    -   Yellow: `#FFFFE0`
    -   Mint: `#98FF98`
- **Shapes**: Rounded corners (`corner_radius` > 8px). Avoid sharp edges.
- **VFX**: Confetti, sparkles, and ribbons.

## Best Practices
- **Don't Hardcode**: Use the `SeasonalMaterialSwapper` so you can turn *off* Easter after April.
- **NEVER Modify Global Resources**: Always `duplicate()` a StyleBox before changing its properties at runtime, or you will affect every node in the game using that style.
- **Juice**: Easter is high-energy. Things should pop, bounce, and wiggle.

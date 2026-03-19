---
name: godot-theme-easter
description: Use when applying a specific Easter holiday theme (Eggs, Bunnies, Pastels) to a game.
---

# Easter Theme (Aesthetics & Juice)

## Overview
This skill provides the assets and logic to "Easter-fy" a game. It focuses on the **Classic Easter** aesthetic: bright pastels, bouncy animations, and egg/bunny iconography.

## Core Components (Expert Easter Tools)

### [easter_squash_stretch_juice.gd](../scripts/theme_easter_easter_squash_stretch_juice.gd)
Expert 'Squash and Stretch' logic for organic egg-like interactions using Tweens.

### [easter_runtime_ui_themer.gd](../scripts/theme_easter_easter_runtime_ui_themer.gd)
Runtime theme injector for applying mass pastel styles across the UI tree.

### [easter_shimmer_vfx_emitter.gd](../scripts/theme_easter_easter_shimmer_vfx_emitter.gd)
Professional 'Hidden Item' shimmer effect with additive blending and scale curves.

### [easter_seasonal_activation_gate.gd](../scripts/theme_easter_easter_seasonal_activation_gate.gd)
Date-aware manager for automatic activation of seasonal event content.

### [easter_egg_collection_tracker.gd](../scripts/theme_easter_easter_egg_collection_tracker.gd)
Expert registry for tracking hidden items with signal-based progression signals.

### [easter_mesh_painter_override.gd](../scripts/theme_easter_easter_mesh_painter_override.gd)
Seasonal 3D material swapper using surface overrides to preserve base assets.

### [easter_wobble_physics_body.gd](../scripts/theme_easter_easter_wobble_physics_body.gd)
Instability-driven physics body for 'Egg-like' wobbly movement.

### [easter_camera_pop_juice.gd](../scripts/theme_easter_easter_camera_pop_juice.gd)
Immersive FOV 'kick' logic to emphasize collection or pop events.

### [easter_confetti_canon_vfx.gd](../scripts/theme_easter_easter_confetti_canon_vfx.gd)
Celebratory confetti explosion with multi-colored pastel flakes.

### [easter_pastel_color_palette.gd](../scripts/theme_easter_easter_pastel_color_palette.gd)
Static utility containing curated, harmonious Easter color tokens.

## Visual Guidelines
- **Colors**:
    -   Pink: `#FFC1CC`
    -   Cyan: `#E0FFFF`
    -   Yellow: `#FFFFE0`
    -   Mint: `#98FF98`
- **Shapes**: Rounded corners (`corner_radius` > 8px). Avoid sharp edges.
- **VFX**: Confetti, sparkles, and ribbons.

## NEVER Do (Expert Easter Rules)

### Aesthetics & Juice
- **NEVER use sharp edges or high-contrast blacks** — Easter aesthetics favor rounded corners (`corner_radius > 12`) and soft pastel tones.
- **NEVER use standard linear scaling for pops** — Linear scaling feels 'robotic.' Always use `TRANS_ELASTIC` or `TRANS_QUART` for organic eggs.
- **NEVER use billboarding for Easter particles** — In close-up UI or VR, billboard sparkles look flat. Use mesh-based particles or axial rotation.

### Logic & Performance
- **NEVER modify the original .mesh or .tres resource** — Swapping materials on a shared Resource changes it for EVERY instance in the game. Always use `surface_override` or `duplicate()`.
- **NEVER run date-checks in _process** — Checking the system calendar every frame is wasteful. Run `Time.get_date_dict_from_system()` once on `_ready` or event trigger.
- **NEVER ignore the 'No-Seasonal' toggle** — Some players hate seasonal overrides. Always provide a 'Disable Seasonal Themes' option in settings.

### Polish
- **NEVER have 'Static' collectibles** — If a player finds an egg, it MUST react (wobble, sparkle, or pop). Dead items feel like bugs.
- **NEVER skip the camera feedback** — A collect event without a subtle camera shake or lens kick feels 'hollow.'

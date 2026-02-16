> [!NOTE]
> **Resource Context**: This module provides expert patterns for **3D Lighting**. Accessed via Godot Master.

# 3D Lighting

Expert guidance for high-performance 3D lighting, shadowing, and real-time Global Illumination (GI) in Godot.

## Available Scripts

### [day_night_cycle.gd](../scripts/3d_lighting_day_night_cycle.gd)
Dynamic sun position and color based on time-of-day. Handles rotation, color temperature shifts, and intensity curves.

### [light_probe_manager.gd](../scripts/3d_lighting_light_probe_manager.gd)
VoxelGI and SDFGI management for advanced global illumination setup.

### [lighting_manager.gd](../scripts/3d_lighting_lighting_manager.gd)
Dynamic light pooling and LOD. Manages automated light culling and shadow toggling based on camera distance for massive performance gains.

### [volumetric_fx.gd](../scripts/3d_lighting_volumetric_fx.gd)
Volumetric fog and light shaft (god ray) configuration with runtime adjustment support.


## NEVER Do

- **NEVER use VoxelGI without tightly defined bounds** — Unbound VoxelGI will cripple performance. Fit the `size` property exactly to your playable area.
- **NEVER enable shadows on every light** — Shadows are expensive; use them only for primary light sources (e.g., the sun and a few local fires).
- **NEVER use LightmapGI for fully dynamic geometry** — Lightmaps are baked; moving objects will not update the lightmap data at runtime.
- **NEVER set OmniLight3D ranges too large** — Keep the radius as small as possible to minimize the number of objects affected by overlap.

---

## Light Types

### DirectionalLight3D
Best for sun/moon. Use `SHADOW_PARALLEL_4_SPLITS` for large outdoor scenes to ensure high-quality shadows both near the camera and at a distance.

### OmniLight3D
Point lights for localized illumination. Use quadratic attenuation (`2.0`) for physically accurate falloff.

### SpotLight3D
Conical light for flashlights and spotlights. Supports `light_projector` textures for cookie/gobo effects.

## Global Illumination (GI) Patterns

| Technique | Use Case |
|-----------|----------|
| **VoxelGI** | Indoor, medium rooms, supports dynamic objects. |
| **SDFGI** | Large outdoor scenes, automated, higher baseline cost. |
| **LightmapGI** | Best for mobile/low-end, fully static geometry only. |

## Performance Optimization (Light Budgets)
Aim for a maximum of 1-2 shadow-casting DirectionalLights and 3-5 shadow-casting local lights. Disable shadows on minor ambient sources like candles or small HUD glows.

## Environment Interaction
Light interacts with the `WorldEnvironment` through scattering. Ensure your environment uses `Background Mode: Sky` and `Ambient Source: Sky` to allow GI and HDRI data to contribute to the scene's lighting.

## Reference
- [Godot Docs: 3D Lighting and Shadows](https://docs.godotengine.org/en/stable/tutorials/3d/lights_and_shadows.html)
- [Godot Docs: Global Illumination](https://docs.godotengine.org/en/stable/tutorials/3d/global_illumination.html)

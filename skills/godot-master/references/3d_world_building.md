> [!NOTE]
> **Resource Context**: This module provides expert patterns for **3D World Building**. Accessed via Godot Master.

# 3D World Building

Expert guidance for 3D level design using GridMap, MeshLibrary, CSG (Constructive Solid Geometry), and environmental setup.

## Available Scripts

### [collision_gen.gd](../scripts/3d_world_building_collision_gen.gd)
Automatic collision shape generation from meshes. Essential for importing models without native collision or for procedural geometry.

### [gridmap_runtime_builder.gd](../scripts/3d_world_building_gridmap_runtime_builder.gd)
Runtime GridMap tile placement with batch operations and auto-navigation baking.

### [csg_bake_tool.gd](../scripts/3d_world_building_csg_bake_tool.gd)
EditorScript to bake CSG geometry to static meshes with proper materials and collision. Essential for finalizing prototypes.

### [lod_manager.gd](../scripts/3d_world_building_lod_manager.gd)
Level-of-detail switching based on camera distance to manage large-scale outdoor scenes.

### [occlusion_setup.gd](../scripts/3d_world_building_occlusion_setup.gd)
OccluderInstance3D configuration for manual occlusion culling, optimized for complex indoor levels.


## NEVER Do

- **NEVER forget to bake GridMap navigation** — GridMaps do not auto-generate navigation meshes; ensure you use a NavigationRegion3D.
- **NEVER use CSG for final game geometry** — Use CSG for prototyping only; bake it to static meshes for production performance.
- **NEVER scale GridMap cell size after placing tiles** — Misalignment will occur. Set your `cell_size` once before beginning placement.
- **NEVER use MeshLibrary items without collision shapes** — Players will fall through visual-only geometry.
- **NEVER enable volumetric fog without a DirectionalLight3D** — Fog requires light to scatter; without a light source, it will be invisible.

---

## GridMap Fundamentals
GridMap allows for high-performance tile-based 3D level construction using a `MeshLibrary`. Use `local_to_map` and `map_to_local` to translate between world space and grid coordinates.

## Constructive Solid Geometry (CSG)
Use CSG for rapid prototyping of rooms and structures.
- **Union**: Combine two shapes.
- **Subtraction**: Cut one shape out of another (e.g., doors, windows).
- **Intersection**: Keep only the overlapping part.

## WorldEnvironment & Sky
Configure the `Environment` resource within a `WorldEnvironment` node to control global lighting and atmosphere.
- **ProceduralSkyMaterial**: Standard sky with adjustable sun and horizon.
- **PanoramaSkyMaterial**: Use HDRI (High Dynamic Range Images) for realistic, baked lighting and reflections.

## Fog & Volumetrics
- **Exponential/Depth Fog**: Classic distance-based atmosphere.
- **Volumetric Fog**: Physically-based light scattering. Requires `DirectionalLight3D` to be visible and effective.

## Optimization: Occlusion Cashing
For complex scenes, use `OccluderInstance3D` to cull objects hidden behind large walls or buildings, significantly reducing draw calls.

## Reference
- [Godot Docs: Using GridMaps](https://docs.godotengine.org/en/stable/tutorials/3d/using_gridmaps.html)
- [Godot Docs: Prototyping with CSG](https://docs.godotengine.org/en/stable/tutorials/3d/csg_tools.html)
- [Godot Docs: World Environment](https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html)

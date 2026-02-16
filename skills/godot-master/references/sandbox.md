> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Sandbox**. Accessed via Godot Master.

# Genre: Sandbox

Expert blueprint for building Sandbox and Creative-focused games. Focuses on high-performance voxel management (Chunks), emergent element systems (Cellular Automata), and efficient world serialization (Run-Length Encoding).

## Available Scripts

### [voxel_chunk_manager.gd](../scripts/sandbox_voxel_chunk_manager.gd)
A professional-grade chunk management system for 3D voxel worlds. Utilizing `MultiMeshInstance3D`, it allows for the rendering of millions of blocks by grouping them into discrete chunks and only updating the GPU buffer when modifications occur.

### [cellular_automata_liquid.gd](../scripts/sandbox_cellular_automata_liquid.gd)
An optimized 2D fluid simulation (Falling Sand style). Uses property-based density checks to simulate liquids, gases, and powders flowing through a grid-based world without the overhead of the physics engine.

### [voxel_world.gd](../scripts/sandbox_voxel_world.gd)
The top-level world controller. Manages the global grid state, facilitates tool-based world editing (Painting blocks), and handles the loading/unloading of chunks as the player moves.


## NEVER Do

- **NEVER use individual `RigidBody` nodes for every block** — Real-time physics for 1,000+ individual voxels will instantly crash your performance. Use **Static Colliders** for the world and only reserve `RigidBody` for small-scale player dynamic objects (props).
- **NEVER simulate the entire world every frame** — Only process "Dirty" chunks (regions with active simulation or recent changes). Sleeping chunks should consume zero CPU. Use **Spatial Hashing** to track which regions are active.
- **NEVER save raw arrays of every block transform** — A large world can contain millions of blocks. Use **Run-Length Encoding (RLE)** (e.g., "Air x 50,000") to compress empty or uniform spaces. This can achieve 100x+ compression for sandbox save files.
- **NEVER update `MultiMesh` buffers every frame** — Rebuilding a GPU buffer is expensive. Batch your changes and only rebuild the `MultiMesh` when the player completes a building action or when a simulation tick resolves.
- **NEVER use `Node` for every grid cell** — Godot's Nodes have significant memory overhead. For deep sandbox grids, store data in raw `PackedInt32Array` or typed `Dictionaries` to keep memory usage in megabytes rather than gigabytes.
- **NEVER hardcode element interactions** — Avoid `if wood and fire: burn()`. Instead, use a **Property System**: If an element's `temperature` > `ignition_point`, trigger a `state_change`. This allows players to discover emergent combinations you didn't explicitly code.

---

## 3D Rendering: Chunked MultiMeshes
- Divide your world into **16x16x16** chunks.
- Each chunk is a single `MultiMeshInstance3D`.
- When a block is broken, only the local chunk's MultiMesh is updated, leaving the rest of the world untouched.

## 2D Simulation: Cellular Automata
For elements like Sand, Water, or Lava:
- Top-Down Pass: Loop through the grid from the bottom up to ensure particles don't "double-move" in a single frame.
- Density Check: if `current_particle.density > target_particle.density`, swap their positions. This creates natural-feeling buoyancy and sedimentation.

## Emergent Element Data (Resources)
Define elements using `Resource` files:
- `density`: float (relative weight)
- `flammability`: float (chance to catch fire)
- `state_transitions`: Dictionary (what happens when heat is applied)
This allows you to add elements like "Acid," "Steam," or "Concrete" without changing the core simulation code.

## Tool Logic: Voxel Painting
- Don't iterate over every block. Use **Grid Quantization**:
- `var target_cell = floor(mouse_world_pos / cell_size)`
- Apply the modification directly to the grid Dictionary at that coordinate.

## Performance: Multi-Threading
- Background Generation: Generating a new 3D chunk (Perlin Noise calculations) should happen on a background `Thread` so the player doesn't experience "Micro-Stuttering" while traveling.

## Reference
- [Godot Docs: Optimizing Voxel Rendering](https://docs.godotengine.org/en/stable/tutorials/performance/using_multimesh.html)
- [Design Architecture of Minecraft (GDC)](https://www.youtube.com/watch?v=F9t9daZ0mEc)

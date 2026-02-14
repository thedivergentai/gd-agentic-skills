> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Simulation / Tycoon**. Accessed via Godot Master.

# Genre: Simulation / Tycoon

Expert blueprint for building Simulation, Tycoon, and Management games. Focuses on tick-based simulation architectures, complex economic feedback loops, and time-scaling systems.

## Available Scripts

### [sim_tick_manager.gd](../scripts/godot-genre-simulation_sim_tick_manager.gd)
The heart of the simulation. Implements a "Tick" system that decouples heavy logic from the rendering framerate. Supports variable game speeds (Paused, Normal, Fast, Ultra) and batch entity processing.

### [tycoon_economy.gd](../scripts/godot-genre-simulation_tycoon_economy.gd)
A sophisticated multi-resource economic engine. Handles currency (using integer cents for precision), reputation, energy, and material tracking with event-driven signals for UI updates.


## NEVER Do

- **NEVER use floating-point for primary currency** — Floats suffer from precision errors (e.g., $1.10 * 3 = $3.29999). ALWAYS use **Integer Cents** (e.g., 330 cents) to ensure mathematical accuracy in a financial simulation.
- **NEVER process 1000+ entities every frame** — Running business logic or NPC AI for thousands of units at 60fps will crash performance. Use a **Tick Manager** to process entities in batches, or update them once per game-second.
- **NEVER hide critical metrics from the player** — Simulation games are about optimization. If a player can't see their Income vs. Expense breakdown, they cannot make informed strategic choices. Transparency is paramount.
- **NEVER use linear cost scaling** — If Level 1 costs $10 and Level 100 costs $1000, the game becomes trivially easy. Use **Exponential Growth** (e.g., `Base * pow(1.15, Level)`) to maintain challenge and strategic tension.
- **NEVER let the early game be a "Waiting Room"** — If the player has to wait 5 real minutes before their first building is finished, they will quit. Front-load decisions and quick early-game wins to build momentum.
- **NEVER allow unlimited resource storage without trade-offs** — Part of the tycoon strategy is managing logistical caps. Forcing the player to build warehouses or upgrade silos creates critical gameplay loops.

---

## Tick-Based Architecture
Management games should not run on `_process()`. Use a `Timer` or a delta-accumulator to trigger a `simulation_tick`:
- **Fast Speed**: Ticks every 0.1s.
- **Normal Speed**: Ticks every 0.5s.
- This allows the simulation to remain consistent regardless of the player's hardware.

## Economic Feedback Loops
- **Positive Loop**: Investment -> Production -> Profit -> More Investment.
- **Negative Loop**: Growth -> Pollution/Reputation Loss -> Lower Demand -> Less Profit.
Successful simulations balance these two loops to prevent runaway success or inevitable failure.

## Time Management
Provide 3 settings for time:
1. **Paused**: Stop all simulation logic but allow UI/Building.
2. **Normal**: 1 Real Second = 1 Game Hour.
3. **Fast (Skip)**: Skip ahead to the next morning or next production cycle.

## Visual Feedback: "Ghost" Building
- When a player selects a building, show a semi-transparent "Ghost" at the mouse position.
- Validate the position (e.g., "Is on suitable terrain?") and turn red if invalid.
- Use `GridMap` (3D) or `TileMap` (2D) to snap placements to a logical grid.

## Stats & Graphs
Players love data.
- Maintain an `Array` of historical data points for the last 30 game-days.
- Use `Line2D` or a custom Shader to draw simple line graphs of the player's Profit over time.

## Reference
- [Godot Docs: Integers vs Floats](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#built-in-types)
- [GDC: The Pacing of Tycoon Games](https://www.youtube.com/watch?v=kYv9lS9eU0U)

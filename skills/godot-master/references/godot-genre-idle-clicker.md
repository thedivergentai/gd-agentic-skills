> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Idle / Clicker**. Accessed via Godot Master.

# Genre: Idle / Clicker

Expert blueprint for building Idle and Incremental games. Focuses on handling ultra-large numbers (beyond standard float limits), exponential growth balancing, and offline progress simulation.

## Available Scripts

### [big_number.gd](../scripts/godot-genre-idle-clicker_big_number.gd)
The foundation of high-scale idle games. Implements a custom "BigNumber" class using Mantissa + Exponent (e.g., `1.5e300`). Supports basic arithmetic (add, multiply, compare) far beyond Godot's standard 64-bit float limit (~1.8e308).

### [generator.gd](../scripts/godot-genre-idle-clicker_generator.gd)
A generic template for "Auto-Clicker" units. Handles the logic for increasing costs (exponentially), calculating production rates, and managing count-based upgrades.

### [scientific_notation_formatter.gd](../scripts/godot-genre-idle-clicker_scientific_notation_formatter.gd)
A utility for making massive numbers readable. Formats big numbers into standard suffixes (K, M, B, T, etc.) or scientific notation for the UI.


## NEVER Do

- **NEVER use standard floats for currency** — Idle games quickly exceed 1e308, which causes floats to return `INF`. Always implement a **BigNumber** system (Mantissa/Exponent) from the start of development.
- **NEVER use `Timer` nodes for revenue generation** — Timers are subject to drift, especially when the framerate fluctuates or the game is paused. Use a manual accumulator in `_process(delta)` for perfect precision.
- **NEVER update all UI labels every frame** — If you have 100 generators, updating 100 labels 60 times a second will tank performance. Only update a label via **Signals** when the underlying value actually changes.
- **NEVER ignore Offline Progress** — Players expect their numbers to go up while the app is closed. Store the `Time.get_unix_time_from_system()` on exit and calculate `seconds_offline * total_revenue` upon re-opening.
- **NEVER make the "Prestige" reset feel like a loss** — If a player resets their progress, they must be rewarded with a global multiplier that makes the next run **significantly** faster (2-5x). If it feels too slow, players will quit.
- **NEVER hardcode generator costs** — Use an exponential formula: `Cost = BasePrice * pow(GrowthFactor, OwnedCount)`. The standard industry growth factor is `1.15x`.

---

## Big Number Normalization
To keep your numbers accurate, always normalize the mantissa:
- If `mantissa >= 10`: `mantissa /= 10`; `exponent += 1`.
- This ensures every number is stored as `X.YYY * 10^Z`.

## Offline Revenue Logic
1. **On Save**: Store `unix_timestamp`.
2. **On Load**: `time_diff = current_timestamp - last_save_timestamp`.
3. **Yield**: `money += total_rps * time_diff`.
4. **Juice**: Show a "Welcome Back! You earned 1.2M while away" popup to reinforce the idle loop.

## The Click Interaction
To prevent boring "Clicking":
- Trigger a "Number Pop" (floating text) at the mouse position.
- Add a slight "Punch" scale effect to the object being clicked.
- Use `Engine.get_frames_per_second()` to cap the maximum clicks per second to prevent macro-abuse (if desired).

## Balancing Progress
- **Tier 1**: Clicking (Manual)
- **Tier 2**: Simple Generators (Auto)
- **Tier 3**: Multipliers (Buffs to T2)
- **Tier 4**: Prestige (Global reset for permanent multipliers)

## Formatting Reference
- **K**: Thousand (10^3)
- **M**: Million (10^6)
- **B**: Billion (10^9)
- **T**: Trillion (10^12)
- **Qa**: Quadrillion (10^15)
- **Qi**: Quintillion (10^18)

## Reference
- [Idle Game Design: The Math of Exponential Growth](https://blog.kongregate.com/the-math-of-idle-games-part-1/)
- [Godot Docs: Handling Large Numbers](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)

---
name: godot-genre-idle-clicker
description: "Expert blueprint for idle/clicker games including big number handling (mantissa + exponent system), exponential growth curves (cost_growth_factor 1.15x), generator systems (auto-producers), offline progress calculation, prestige systems (reset for permanent multipliers), number formatting (K/M/B suffixes, scientific notation). Use for incremental games, idle games, or cookie clicker derivatives. Trigger keywords: idle_game, big_number, exponential_growth, generator_system, offline_progress, prestige_system, number_formatting."
---

# Genre: Idle / Clicker

Expert blueprint for idle/clicker games with exponential progression and prestige mechanics.

## NEVER Do (Expert Anti-Patterns)

### Economics & Math
- NEVER use standard floats for currency; strictly implement a **BigNumber** (Mantissa/Exponent) system (e.g., `1.5e300`) to prevent `INF` crashes at 1e308.
- NEVER use `Timer` nodes for revenue generation; strictly use a manual accumulator in `_process(delta)` to prevent drift during frame fluctuations.
- NEVER hardcode generator costs or growth; strictly use an exponential formula: `Cost = BasePrice * pow(GrowthFactor, OwnedCount)` (industry standard **1.15x**).
- NEVER evaluate exact float equality (`==`); strictly use `is_equal_approx()` or `>=` to prevent "stuck" progress due to precision loss.
- NEVER parse scientific notation strings with `to_int()`; strictly use `to_float()` or a dedicated BigNumber parser.

### Performance & Optimization
- NEVER update all UI labels every frame; strictly use **Signals** to update labels ONLY when values change, or throttle updates to 10 FPS.
- NEVER ignore **Low Processor Usage Mode** for mobile; strictly enable `OS.low_processor_usage_mode = true` to preserve battery life.
- NEVER instantiate/delete hundreds of text nodes per second; strictly use **Object Pooling** or `MultiMeshInstance` for click-feedback.
- NEVER update massive logs by modifying the `text` property; strictly use `append_text()` to prevent main thread blocking.

### Player Experience & Persistence
- NEVER ignore **Offline Progress**; strictly calculate `seconds_offline * total_revenue` using system UNIX timestamps (`Time.get_unix_time_from_system()`).
- NEVER make the "Prestige" reset feel like a loss; strictly provide a global multiplier that makes the next run **significantly** faster (2-5x).
- NEVER calculate offline time using `Time.get_ticks_msec()`; strictly use **Persistent UNIX timestamps** as ticks reset on app restart.
- NEVER use Node hierarchies for raw data; strictly use `RefCounted` or `Resource` objects for lightweight, serializable logic.

---

## 🛠 Expert Components (scripts/)

### Original Expert Patterns
- [big_number.gd](../scripts/genre_idle_clicker_idle_performance_setup.gd) - The foundation for handling e308+ scales using Mantissa + Exponent math.
- [generator.gd](../scripts/genre_idle_clicker_precision_cost_validator.gd) - Generic template for exponential cost units and rate calculation.
- [scientific_notation_formatter.gd](../scripts/genre_idle_clicker_scientific_notation_math.gd) - readable formatting for K, M, B, T suffixes and scientific notation.

### Modular Components
- [offline_progress_calculator.gd](../scripts/genre_idle_clicker_offline_progress_calculator.gd) - Real-world delta tracking using UNIX timestamps.
- [functional_income_reducer.gd](../scripts/genre_idle_clicker_functional_income_reducer.gd) - C++ optimized array reduction for fast income summation.
- [threaded_catchup_simulator.gd](../scripts/genre_idle_clicker_threaded_catchup_simulator.gd) - WorkerThreadPool background simulation patterns.

---

## Core Loop
1.  **Click**: Player performs manual action to gain currency.
2.  **Buy**: Player purchases "generators" (auto-clickers).
3.  **Wait**: Game plays itself, numbers go up.
4.  **Upgrade**: Player buys multipliers to increase efficiency.
5.  **Prestige**: Player resets progress for a permanent global multiplier.

## Skill Chain

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Math | `godot-gdscript-mastery` | Handling numbers larger than 64-bit float |
| 2. UI | `godot-ui-containers`, `labels` | Displaying "1.5e12" or "1.5T" cleanly |
| 3. Data | `godot-save-load-systems` | Saving progress, offline time calculation |
| 4. Logic | `signals` | Decoupling UI from the economic simulation |
| 5. Meta | `json-serialization` | Balancing hundreds of upgrades via data |

## Architecture Overview

### 1. Big Number System
Standard `float` goes to `INF` around 1.8e308. Idle games often go beyond.
You need a custom `BigNumber` class (Mantissa + Exponent).

```gdscript
# big_number.gd
class_name BigNumber

var mantissa: float = 0.0 # 1.0 to 10.0
var exponent: int = 0     # Power of 10

func _init(m: float, e: int) -> void:
    mantissa = m
    exponent = e
    normalize()

func normalize() -> void:
    if mantissa >= 10.0:
        mantissa /= 10.0
        exponent += 1
    elif mantissa < 1.0 and mantissa != 0.0:
        mantissa *= 10.0
        exponent -= 1
```

### 2. Generator System
The core entities that produce currency.

```gdscript
# generator.gd
class_name Generator extends Resource

@export var id: String
@export var base_cost: BigNumber
@export var base_revenue: BigNumber
@export var cost_growth_factor: float = 1.15

var count: int = 0

func get_cost() -> BigNumber:
    # Cost = Base * (Growth ^ Count)
    return base_cost.multiply(pow(cost_growth_factor, count))
```

### 3. Simulation Manager (Offline Progress)
Calculating gains while the game was closed.

```gdscript
# game_manager.gd
func _ready() -> void:
    var last_save_time = save_data.timestamp
    var current_time = Time.get_unix_time_from_system()
    var seconds_offline = current_time - last_save_time
    
    if seconds_offline > 60:
        var revenue = calculate_revenue_per_second().multiply(seconds_offline)
        add_currency(revenue)
        show_welcome_back_popup(revenue)
```

## Key Mechanics Implementation

### Prestige System (Reset)
Resetting `generators` but keeping `prestige_currency`.

```gdscript
func prestige() -> void:
    if current_money.less_than(prestige_threshold):
        return
        
    # Formula: Cube root of money / 1 million
    # (Just an example, depends on balance)
    var gained_keys = calculate_prestige_gain()
    
    save_data.prestige_currency += gained_keys
    save_data.global_multiplier = 1.0 + (save_data.prestige_currency * 0.10)
    
    # Reset
    save_data.money = BigNumber.new(0, 0)
    save_data.generators = ResetGenerators()
    save_game()
    reload_scene()
```

### Formatting Numbers
Displaying `1234567` as `1.23M`.

```gdscript
static func format(bn: BigNumber) -> String:
    if bn.exponent < 3:
        return str(int(bn.mantissa * pow(10, bn.exponent)))
    
    var suffixes = ["", "K", "M", "B", "T", "Qa", "Qi"]
    var suffix_idx = bn.exponent / 3
    
    if suffix_idx < suffixes.size():
        return "%.2f%s" % [bn.mantissa * pow(10, bn.exponent % 3), suffixes[suffix_idx]]
    else:
        return "%.2fe%d" % [bn.mantissa, bn.exponent]
```

## Godot-Specific Tips

*   **Timers**: Do NOT use `Timer` nodes for revenue generation (drifting). Use `_process(delta)` and accumulate time.
*   **GridContainer**: Perfect for the "Generators" list.
*   **Resources**: Use `.tres` files to define every generator (Farm, Mine, Factory) so you can tweak balance without touching code.

## Common Pitfalls

1.  **Floating Point Errors**: Using standard `float` for money. **Fix**: Use BigNumber implementation immediately.
2.  **Boring Prestige**: Resetting feels like a punishment. **Fix**: Ensure the post-prestige run is *significantly* faster (2x-5x speed).
3.  **UI Lag**: Updating 50 text labels every frame. **Fix**: Only update labels when values actually change (Signal-based), or throttling updates to 10fps.


## Reference
- Master Skill: [godot-master](../SKILL.md)

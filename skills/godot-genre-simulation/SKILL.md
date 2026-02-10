---
name: godot-genre-simulation
description: "Expert blueprint for simulation and tycoon games (SimCity, RollerCoaster Tycoon, Factorio, Two Point Hospital) covering economy management, time progression, interconnected systems, NPC simulation, and feedback loops. Use when building management sims, tycoon games, city builders, or resource optimization games. Keywords tycoon, economy system, resource management, time scale, feedback loop, progression unlock, simulation tick."
---

# Genre: Simulation / Tycoon

Optimization, systems mastery, and satisfying feedback loops define management games.

## Available Scripts

### [sim_tick_manager.gd](scripts/sim_tick_manager.gd)
Expert tick-based simulation with variable speed control and batch processing.

## Core Loop

`Invest → Build/Manage → Generate Income → Optimize → Expand`

## NEVER Do in Simulation Games

- **NEVER process every simulated entity individually in `_process()`** — Batch updates in fixed ticks (e.g., once per second). Simulating 1000 businesses individually = 60k calls/second. Batch = 1k calls/second.
- **NEVER use floating-point for currency** — `float` accumulates rounding errors. $1.10 * 3 = $3.2999999. Use `int` cents: `1100 * 3 = 3300` cents = $33.00 exact.
- **NEVER let early game be dull waiting** — Front-load decision points. First 5 minutes must hook players. Don't make them wait 10 real minutes for first unlock.
- **NEVER use linear cost scaling** — Buildings that cost `10 * level` break at level 100 (1000 cost). Use exponential: `BASE * pow(1.5, level)` creates meaningful trade-offs.
- **NEVER hide critical numbers from players** — Show income/expense breakdown, production rates, efficiency %. Optimization games require transparency.
- **NEVER allow infinite resource stacking without consequence** — Storage caps create interesting decisions. Unlimited resources remove strategy.
- **NEVER update UI labels every frame** — Updating 50 UI labels @60fps = 3000 updates/sec. Use signals: update only when value changes.

---

## Economy Design

The heart of any tycoon game is its economy. Key principle: **multiple interconnected resources that force trade-offs**.

### Multi-Resource System

```gdscript
class_name TycoonEconomy
extends Node

signal resource_changed(resource_type: String, amount: float)
signal went_bankrupt

var resources: Dictionary = {
    "money": 10000.0,
    "reputation": 50.0,  # 0-100
    "workers": 0,
    "materials": 100.0,
    "energy": 100.0
}

var resource_caps: Dictionary = {
    "reputation": 100.0,
    "workers": 50,
    "energy": 1000.0
}

func modify_resource(type: String, amount: float) -> bool:
    if amount < 0 and resources[type] + amount < 0:
        if type == "money":
            went_bankrupt.emit()
        return false  # Can't go negative
    
    resources[type] = clamp(
        resources[type] + amount,
        0,
        resource_caps.get(type, INF)
    )
    resource_changed.emit(type, resources[type])
    return true
```

### Income/Expense Tracking

```gdscript
class_name FinancialTracker
extends Node

var income_sources: Dictionary = {}  # source_name: amount_per_tick
var expense_sources: Dictionary = {}

signal financial_update(profit: float, income: float, expenses: float)

func calculate_tick() -> float:
    var total_income := 0.0
    var total_expenses := 0.0
    
    for source in income_sources.values():
        total_income += source
    
    for source in expense_sources.values():
        total_expenses += source
    
    var profit := total_income - total_expenses
    financial_update.emit(profit, total_income, total_expenses)
    return profit
```

---

## Time System

Simulation games need controllable time:

```gdscript
class_name SimulationTime
extends Node

signal time_tick(delta_game_hours: float)
signal day_changed(day: int)
signal speed_changed(new_speed: int)

enum Speed { PAUSED, NORMAL, FAST, ULTRA }

@export var seconds_per_game_hour := 30.0  # Real seconds

var current_speed := Speed.NORMAL
var speed_multipliers := {
    Speed.PAUSED: 0.0,
    Speed.NORMAL: 1.0,
    Speed.FAST: 3.0,
    Speed.ULTRA: 10.0
}

var current_hour := 8.0  # Start at 8 AM
var current_day := 1

func _process(delta: float) -> void:
    if current_speed == Speed.PAUSED:
        return
    
    var game_delta := (delta / seconds_per_game_hour) * speed_multipliers[current_speed]
    current_hour += game_delta
    
    if current_hour >= 24.0:
        current_hour -= 24.0
        current_day += 1
        day_changed.emit(current_day)
    
    time_tick.emit(game_delta)

func set_speed(speed: Speed) -> void:
    current_speed = speed
    speed_changed.emit(speed)
```

---

## Entity Management

### Workers/NPCs

```gdscript
class_name Worker
extends Node

enum State { IDLE, WORKING, RESTING, COMMUTING }

@export var wage_per_hour: float = 10.0
@export var skill_level: float = 1.0  # Productivity multiplier
@export var morale: float = 80.0  # 0-100

var current_state := State.IDLE
var assigned_workstation: Workstation

func update(game_hours: float) -> void:
    match current_state:
        State.WORKING:
            if assigned_workstation:
                var productivity := skill_level * (morale / 100.0)
                assigned_workstation.work(game_hours * productivity)
                morale -= game_hours * 0.5  # Working tires workers
        State.RESTING:
            morale = min(100.0, morale + game_hours * 2.0)

func calculate_hourly_cost() -> float:
    return wage_per_hour
```

### Buildings/Facilities

```gdscript
class_name Facility
extends Node3D

@export var build_cost: Dictionary  # resource_type: amount
@export var operating_cost_per_hour: float = 5.0
@export var capacity: int = 5
@export var output_per_hour: Dictionary  # resource_type: amount

var assigned_workers: Array[Worker] = []
var is_operational := true
var efficiency := 1.0

func calculate_output(game_hours: float) -> Dictionary:
    if not is_operational or assigned_workers.is_empty():
        return {}
    
    var worker_efficiency := 0.0
    for worker in assigned_workers:
        worker_efficiency += worker.skill_level * (worker.morale / 100.0)
    worker_efficiency /= capacity  # Normalize to 0-1
    
    var result := {}
    for resource in output_per_hour:
        result[resource] = output_per_hour[resource] * game_hours * worker_efficiency * efficiency
    return result
```

---

## Customer/Demand System

```gdscript
class_name CustomerSimulation
extends Node

@export var base_customers_per_hour := 10.0
@export var demand_curve: Curve  # Hour of day vs demand multiplier

var customer_queue: Array[Customer] = []

func generate_customers(game_hour: float, delta_hours: float) -> void:
    var demand_mult := demand_curve.sample(game_hour / 24.0)
    var reputation_mult := Economy.resources["reputation"] / 50.0  # 100 rep = 2x customers
    
    var customers_to_spawn := base_customers_per_hour * delta_hours * demand_mult * reputation_mult
    
    for i in int(customers_to_spawn):
        spawn_customer()

func spawn_customer() -> void:
    var customer := Customer.new()
    customer.patience = randf_range(30.0, 120.0)  # Seconds before leaving
    customer.spending_budget = randf_range(10.0, 100.0)
    customer_queue.append(customer)
```

---

## Feedback Systems

### Visual Feedback

```gdscript
# Money flying to bank, resources flowing, etc.
class_name ResourceFlowVisualizer
extends Node

func show_income(amount: float, from: Vector2, to: Vector2) -> void:
    var coin := coin_scene.instantiate()
    coin.position = from
    add_child(coin)
    
    var tween := create_tween()
    tween.tween_property(coin, "position", to, 0.5)
    tween.tween_callback(coin.queue_free)
    
    var label := Label.new()
    label.text = "+$" + str(int(amount))
    label.position = from
    add_child(label)
    
    var label_tween := create_tween()
    label_tween.tween_property(label, "position:y", label.position.y - 30, 0.5)
    label_tween.parallel().tween_property(label, "modulate:a", 0.0, 0.5)
    label_tween.tween_callback(label.queue_free)
```

### Statistics Dashboard

```gdscript
class_name StatsDashboard
extends Control

@export var graph_history_hours := 24
var income_history: Array[float] = []
var expense_history: Array[float] = []

func record_financial_tick(income: float, expenses: float) -> void:
    income_history.append(income)
    expense_history.append(expenses)
    
    # Keep last N entries
    while income_history.size() > graph_history_hours:
        income_history.pop_front()
        expense_history.pop_front()
    
    queue_redraw()

func _draw() -> void:
    # Draw income/expense graph
    draw_line_graph(income_history, Color.GREEN)
    draw_line_graph(expense_history, Color.RED)
```

---

## Progression & Unlocks

```gdscript
class_name UnlockSystem
extends Node

var unlocks: Dictionary = {
    "basic_facility": true,
    "advanced_facility": false,
    "marketing": false,
    "automation": false
}

var unlock_conditions: Dictionary = {
    "advanced_facility": {"money_earned": 50000},
    "marketing": {"reputation": 70},
    "automation": {"workers_hired": 20}
}

var progress: Dictionary = {
    "money_earned": 0.0,
    "workers_hired": 0
}

func check_unlocks() -> Array[String]:
    var newly_unlocked: Array[String] = []
    
    for unlock in unlock_conditions:
        if unlocks[unlock]:
            continue  # Already unlocked
        
        var conditions := unlock_conditions[unlock]
        var all_met := true
        
        for condition in conditions:
            if progress.get(condition, 0) < conditions[condition]:
                all_met = false
                break
        
        if all_met:
            unlocks[unlock] = true
            newly_unlocked.append(unlock)
    
    return newly_unlocked
```

---

## Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Economy too easy to break | Extensive balancing, soft caps, diminishing returns |
| Boring early game | Front-load interesting decisions, quick early progression |
| Information overload | Progressive disclosure, collapsible UI panels |
| No clear goals | Milestones, achievements, scenarios |
| Tedious micromanagement | Automation unlocks, batch operations |

---

## Godot-Specific Tips

1. **UI**: Use `Control` nodes extensively, `Tree` for lists, `GraphEdit` for connections
2. **Performance**: Process entities in batches, not every frame
3. **Save/Load**: Convert all game state to Dictionary for JSON serialization
4. **Isometric view**: Use `Camera2D` with orthographic projection


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)

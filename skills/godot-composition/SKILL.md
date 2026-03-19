---
name: godot-composition
description: "Expert architectural standards for building scalable Godot GAMES (RPGs, Platformers, Shooters) using the Composition pattern (Entity-Component). Use when designing player controllers, NPCs, enemies, weapons, or complex gameplay systems. Enforces \"Has-A\" relationships for game entities. Trigger keywords: Entity-Component, ECS, Gameplay, Actors, NPCs, Enemies, Weapons, Hitboxes, Game Loop, Level Design."
---

# Godot Composition Architecture

## Core Philosophy
This skill enforces **Composition over Inheritance** ("Has-a" vs "Is-a").
In Godot, Nodes **are** components. A complex entity (Player) is simply an Orchestrator managing specialized Worker Nodes (Components).

### The Golden Rules
1.  **Single Responsibility**: One script = One job.
2.  **Encapsulation**: Components are "selfish." They handle their internal logic but don't know *who* owns them.
3.  **The Orchestrator**: The root script (e.g., `player.gd`) does **no logic**. It only manages state and passes data between components.
4.  **Decoupling**: Components communicate via **Signals** (up) and **Methods** (down).

---

## Available Scripts

### [health_component.gd](scripts/health_component.gd)
Specialized Node for managing lifespan, damage logic, and death signals across any entity.

### [hit_box_component.gd](scripts/hit_box_component.gd)
Area-based component for intercepting damage and delegating it to a HealthComponent.

### [hurt_box_component.gd](scripts/hurt_box_component.gd)
Area-based component for dealing damage specifically to HitBoxComponents.

### [velocity_component.gd](scripts/velocity_component.gd)
Encapsulated movement and acceleration logic for reuse across Players and Enemies.

### [interaction_component.gd](scripts/interaction_component.gd)
Decoupled interaction handler using injecting `Callable` logic for context-aware actions.

### [follower_component.gd](scripts/follower_component.gd)
Decoupled tracking logic using `NodePath` injection for smooth entity following.

### [state_component_vsm.gd](scripts/state_component_vsm.gd)
Component-based state machine pattern using child nodes as individual states.

### [status_effect_component.gd](scripts/status_effect_component.gd)
Managing temporary modifiers (buffs/debuffs) by stacking effect scenes as children.

### [visual_sync_component.gd](scripts/visual_sync_component.gd)
Separating logical state (velocity/direction) from visual representation (sprite flipping).

### [composition_root_init.gd](scripts/composition_root_init.gd)
The "Orchestrator" pattern for wiring and connecting components in a parent node.

## NEVER Do in Composition

- **NEVER use deep inheritance chains** (e.g., `Player > Entity > LivingThing > Node`) — Creates brittle "God Classes" that are hard to refactor [21].
- **NEVER use `get_node()` or `$` for components** — This breaks if the scene tree is rearranged. Always use `@export` or `%UniqueNames` [22].
- **NEVER let a component reference its parent script directly** — This makes the component impossible to reuse. Use signals or dependency injection [23].
- **NEVER mix Input, Physics, and Game Logic in one script** — This violates Single Responsibility. Split them into specialized components [24, 13].
- **NEVER create components that require a specific SceneTree structure** — A component should be "selfish" and only care about its own properties and direct children.
- **NEVER use inheritance to "add a feature"** — If you want an enemy to shoot, add a `ShootingComponent`, don't make it inherit from `ShooterEnemy`.
- **NEVER hardcode component dependencies** — If `CombatComponent` needs `HealthComponent`, look it up in `_ready()` or inject it via the parent [11].
- **NEVER treat Godot nodes as pure data** — Nodes provide lifecycle (`_process`) and signals. If you only need data, use a `Resource`.
- **NEVER ignore the Node lifecycle in components** — Use `_enter_tree()` and `_exit_tree()` for setup/cleanup that must happen regardless of the parent's state.
- **NEVER hide component points of access** — Expose `NodePath` or `Callable` properties so the parent can wire the component in the Inspector [13].

---

## Implementation Standards

### 1. Connection Strategy: Typed Exports
Do not rely on tree order. Use explicit dependency injection via `@export` with static typing.

**The "Godot Way" for strict godot-composition:**
```gdscript
# The Orchestrator (e.g., player.gd)
class_name Player extends CharacterBody3D

# Dependency Injection: Define the "slots" in the backpack
@export var health_component: HealthComponent
@export var movement_component: MovementComponent
@export var input_component: InputComponent

# Use Scene Unique Names (%) for auto-assignment in Editor
# or drag-and-drop in the Inspector.
```

### 2. Component Mindset
Components must define `class_name` to be recognized as types.

**Standard Component Boilerplate:**
```gdscript
class_name MyComponent extends Node 
# Use Node for logic, Node3D/2D if it needs position

@export var stats: Resource # Components can hold their own data
signal happened_something(value)

func do_logic(delta: float) -> void:
    # Perform specific task
    pass
```

---

## Standard Components

### The Input Component (The Senses)
**Responsibility**: Read hardware state. Store it. Do NOT act on it.
*State*: `move_dir`, `jump_pressed`, `attack_just_pressed`.

```gdscript
class_name InputComponent extends Node

var move_dir: Vector2
var jump_pressed: bool

func update() -> void:
    # Called by Orchestrator every frame
    move_dir = Input.get_vector("left", "right", "up", "down")
    jump_pressed = Input.is_action_just_pressed("jump")
```

### The Movement Component (The Legs)
**Responsibility**: Manipulate physics body. Handle velocity/gravity.
**Constraint**: Requires a reference to the physics body it moves.

```gdscript
class_name MovementComponent extends Node

@export var body: CharacterBody3D # The thing we move
@export var speed: float = 8.0
@export var jump_velocity: float = 12.0

func tick(delta: float, direction: Vector2, wants_jump: bool) -> void:
    if not body: return
    
    # Handle Gravity
    if not body.is_on_floor():
        body.velocity.y -= 9.8 * delta
        
    # Handle Movement
    if direction:
        body.velocity.x = direction.x * speed
        body.velocity.z = direction.y * speed # 3D conversion
    else:
        body.velocity.x = move_toward(body.velocity.x, 0, speed)
        body.velocity.z = move_toward(body.velocity.z, 0, speed)
        
    # Handle Jump
    if wants_jump and body.is_on_floor():
        body.velocity.y = jump_velocity
        
    body.move_and_slide()
```

### The Health Component (The Life)
**Responsibility**: Manage HP, Clamp values, Signal changes.
**Context Agnostic**: Can be put on a Player, Enemy, or a Wooden Crate.

```gdscript
class_name HealthComponent extends Node

signal died
signal health_changed(current, max)

@export var max_health: float = 100.0
var current_health: float

func _ready():
    current_health = max_health

func damage(amount: float):
    current_health = clamp(current_health - amount, 0, max_health)
    health_changed.emit(current_health, max_health)
    if current_health == 0:
        died.emit()
```

---

## The Orchestrator (Putting it Together)

The Orchestrator (`player.gd`) binds the components in the `_physics_process`. It acts as the bridge.

```gdscript
class_name Player extends CharacterBody3D

@onready var input: InputComponent = %InputComponent
@onready var move: MovementComponent = %MovementComponent
@onready var health: HealthComponent = %HealthComponent

func _ready():
    # Connect signals (The ears)
    health.died.connect(_on_death)

func _physics_process(delta):
    # 1. Update Senses
    input.update()
    
    # 2. Pass Data to Workers (State Management)
    # The Player script decides that "Input Direction" maps to "Movement Direction"
    move.tick(delta, input.move_dir, input.jump_pressed)

func _on_death():
    queue_free()
```

## Performance Note
Nodes are lightweight. Do not fear adding 10-20 nodes per entity. The organizational benefit of Composition vastly outweighs the negligible memory cost of `Node` instances.


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)

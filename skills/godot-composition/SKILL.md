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

## Anti-Patterns (NEVER Do This)
- **NEVER** use deep inheritance chains (e.g., `Player > Entity > LivingThing > Node`). This creates brittle "God Classes."
- **NEVER** use `get_node("Path/To/Thing")` or `$` syntax for components. This breaks if the scene tree changes.
- **NEVER** let components reference the Parent directly (unless absolutely necessary via typed injection).
- **NEVER** mix Input, Physics, and Game Logic in a single script.

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

---
name: godot-composition-apps
description: "Expert architectural standards for building scalable Godot applications (Apps, Tools, UI, or Games) using the Composition pattern. Use when designing node structures, refactoring monolithic scripts, or implementing complex behaviors. Enforces \"Has-A\" relationships over \"Is-A\" inheritance."
---

# Godot Composition & Architecture (Apps & UI)

This skill enforces the **Single Responsibility Principle** within Godot's Node system. Whether building an RPG or a SaaS Dashboard, the rule remains: **One Script = One Job.**

## The Core Philosophy

### The Litmus Test
Before writing a script, ask: **"If I attached this script to a literal rock, would it still function?"**
- **Pass:** An `AuthComponent` on a rock allows the rock to log in. (Context Agnostic)
- **Fail:** A `LoginForm` script on a rock tries to grab text fields the rock doesn't have. (Coupled)

### The Backpack Model (Has-A > Is-A)
Stop extending base classes to add functionality. Treat the Root Node as an empty **Backpack**.
- **Wrong (Inheritance):** `SubmitButton` extends `AnimatedButton` extends `BaseButton`.
- **Right (Composition):** `SubmitButton` (Root) **HAS-A** `AnimationComponent` and **HAS-A** `NetworkRequestComponent`.

## The Hierarchy of Power (Communication Rules)

Strictly enforce this communication flow to prevent "Spaghetti Code":

| Direction | Source → Target | Method | Reason |
|-----------|-----------------|--------|--------|
| **Downward** | Orchestrator → Component | **Function Call** | Manager owns the workers; knows they exist. |
| **Upward** | Component → Orchestrator | **Signals** | Workers are blind; they just yell "I'm done!" |
| **Sideways** | Component A ↔ Component B | **FORBIDDEN** | Siblings must never talk directly. |

**The Sideways Fix:** Component A signals the Orchestrator; Orchestrator calls function on Component B.

## The Orchestrator Pattern

The Root Node script (e.g., `LoginScreen.gd`, `UserProfile.gd`) is now an **Orchestrator**.
- **Math/Logic:** 0%
- **State Management:** 100%
- **Job:** Wire components together. Listen to Component signals and trigger other Component functions.

### Example: App/UI Context

| Concept | App/UI Example |
|---------|----------------|
| **Orchestrator** | `UserProfile.gd` |
| **Component 1** | `AuthValidator` (Logic) |
| **Component 2** | `FormListener` (Input) |
| **Component 3** | `ThemeManager` (Visual) |

## Implementation Standards

### 1. Type Safety
Define components globally. Never use dynamic typing for core architecture.
```gdscript
# auth_component.gd
class_name AuthComponent extends Node
```

### 2. Dependency Injection
**NEVER** use `get_node("Path/To/Child")`. Paths are brittle.
**ALWAYS** use Typed Exports and drag-and-drop in the Inspector.
```gdscript
# Orchestrator script
@export var auth: AuthComponent
@export var form_ui: Control
```

### 3. Scene Unique Names
If internal referencing within a scene is strictly necessary for the Orchestrator, use the `%` Unique Name feature.
```gdscript
@onready var submit_btn = %SubmitButton
```

### 4. Stateless Components
Components should process the data given to them.
- **Bad:** `NetworkComponent` finds the username text field itself.
- **Good:** `NetworkComponent` has a function `login(username, password)`. The Orchestrator passes the text field data into that function.

## NEVER Do (Expert Architectural Rules)

### Hierarchy & Dependencies
- **NEVER use get_parent() to fetch data** — Components must be blind. If they need data, it must be injected via `@export` or passed into a function call.
- **NEVER talk sideways** — `ComponentA` must never call functions on `ComponentB`. High-coupling makes refactoring impossible. Always signal up to the Orchestrator.
- **NEVER use brittle Node Paths** — `get_node("Child/Subchild/Node")` breaks when you move a single node. Use `@export` and the Inspector.

### Logic & State
- **NEVER put business logic in the Orchestrator** — The Orchestrator should only have `_on_signal` methods that delegate to other components.
- **NEVER store global state in individual components** — Use a shared `Context` Resource or the Global Autoload for cross-scene state.
- **NEVER assume a component's parent is of a specific type** — If a `HealthComponent` requires its parent to be a `CharacterBody2D`, it fails the "Rock Test."

### Polish & Orchestration
- **NEVER skip signal cleanup** — Connecting signals dynamically without disconnecting can lead to memory leaks or multiple execution bugs.
- **NEVER let Logic know about Visuals** — A `CombatComponent` should never call `AnimationPlayer.play()`. It emits `attack_performed`, and a `Syncer` or `Orchestrator` handles the visual response.

## Code Structure Example (General App)

### Component: `clipboard_copier.gd`
```gdscript
class_name ClipboardCopier extends Node

signal copy_success
signal copy_failed(reason)

func copy_text(text: String) -> void:
    if text.is_empty():
        copy_failed.emit("Text empty")
        return
    DisplayServer.clipboard_set(text)
    copy_success.emit()
```

### Orchestrator: `share_menu.gd`
```gdscript
extends Control

# Wired via Inspector
@export var copier: ClipboardCopier
@export var link_label: Label

func _ready():
    # Downward communication
    %CopyButton.pressed.connect(_on_copy_button_pressed)
    # Upward communication listening
    copier.copy_success.connect(_on_copy_success)

func _on_copy_button_pressed():
    # Orchestrator delegation
    copier.copy_text(link_label.text)

func _on_copy_success():
    # Orchestrator managing UI state based on signal
    %ToastNotification.show("Link Copied!")
```


## Expert Composition Components

### [comp_orchestrator_base.gd](../scripts/composition_apps_comp_orchestrator_base.gd)
Central hub for signal delegation and component wiring. Logic-free manager.

### [comp_base_component.gd](../scripts/composition_apps_comp_base_component.gd)
Foundational component with type-safe signals and auto-group registration.

### [comp_health_component.gd](../scripts/composition_apps_comp_health_component.gd)
Context-agnostic health/damage logic that works on players, enemies, or barrels.

### [comp_hitbox_component.gd](../scripts/composition_apps_comp_hitbox_component.gd)
Area-based collision interface that bridges physical hits to the HealthComponent.

### [comp_ability_sequencer.gd](../scripts/composition_apps_comp_ability_sequencer.gd)
Dynamic ability manager that executes child 'Ability' nodes via unified interfaces.

### [comp_data_driven_config.gd](../scripts/composition_apps_comp_data_driven_config.gd)
Late-binding configuration loader for hot-swapping behavior via Resources (`.tres`).

### [comp_dependency_injector.gd](../scripts/composition_apps_comp_dependency_injector.gd)
Expert injection pattern for passing refs to dynamic components without `get_node`.

### [comp_persistence_component.gd](../scripts/composition_apps_comp_persistence_component.gd)
Automated save/load registration for modular node persistence.

### [comp_logic_visual_syncer.gd](../scripts/composition_apps_comp_logic_visual_syncer.gd)
Decoupling agent that syncs gameplay logic state to visual animations/VFX.

### [comp_rock_test_boilerplate.gd](../scripts/composition_apps_comp_rock_test_boilerplate.gd)
Architectural validator to ensure components are truly decoupled.

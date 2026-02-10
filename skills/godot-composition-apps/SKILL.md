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

## Anti-Patterns (NEVER DO THIS)

1.  **The Monolith:** A root script that handles UI events, HTTP requests, AND business logic.
2.  **The Chain:** Passing data through 4 layers of nodes to get to the destination. (Use Signals).
3.  **Hard Dependency:** `InputComponent` checking `get_parent().health`. (The component must work on a rock; rocks don't have health).

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


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)

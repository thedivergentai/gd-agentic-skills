---
name: godot-animation-tree-mastery
description: "Expert patterns for AnimationTree including StateMachine transitions, BlendSpace2D for directional movement, BlendTree for layered animations, root motion, transition conditions, advance expressions, and state machine sub-states. Use for complex character animation systems with movement blending and state management. Trigger keywords: AnimationTree, AnimationNodeStateMachine, BlendSpace2D, BlendSpace1D, BlendTree, transition_request, blend_position, advance_expression, AnimationNodeAdd2, AnimationNodeBlend2, root_motion."
---

# AnimationTree Mastery

Expert guidance for Godot's advanced animation blending and state machines.

## NEVER Do

- **NEVER call `play()` on AnimationPlayer when using AnimationTree** — AnimationTree controls the player. Directly calling `play()` causes conflicts and jitter. Use `set("parameters/transition_request")` or `travel()` instead [12].
- **NEVER forget to set `active = true`** — AnimationTree is inactive by default. Animations won't play until `$AnimationTree.active = true` [13].
- **NEVER use absolute paths for parameter access** — Use relative paths like `"parameters/StateMachine/transition_request"`. This ensures compatibility when nodes move in the hierarchy [14].
- **NEVER leave `auto_advance` enabled for interactive states** — It causes immediate transitions. Use it only for automated sequences like combo chains or death-to-respawn [15, 121].
- **NEVER use `BlendSpace2D` for 1D blending** — Blending only speed? Use `BlendSpace1D`. Blending only two states? Use `Blend2`. `BlendSpace2D` is specifically for X+Y directional inputs (strafe) [16, 142].
- **NEVER update `AnimationTree` parameters every frame without a guard** — Setting parameters via `set()` every frame regardless of change causes cache invalidation and potential stutter. Check equality first.
- **NEVER use deep, nested `BlendTrees` for simple logic** — Every layer adds CPU overhead. If logic can be handled in a `StateMachine` or a simple script-driven `Blend2`, do it there.
- **NEVER forget to handle `await get_tree().process_frame` when updating parameters synchronously** — Sometimes the tree needs one frame to reconcile state before the next parameter change takes effect.
- **NEVER rely on `auto_advance` for long cutscenes** — If an animation is interrupted, `auto_advance` can put the character in a broken state. Use `Method Tracks` to signal state completion instead.
- **NEVER use `Sync` groups for animations with wildly different lengths** — It forces one animation to play at an extreme speed. Use `TimeScale` or separate layers for mismatching cycles.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [sync_parameter_manager.gd](scripts/sync_parameter_manager.gd)
Expert management of `AnimationTree` parameters with guards to prevent redundant updates and GPU cache churn.

### [reactive_oneshot_vfx.gd](scripts/reactive_oneshot_vfx.gd)
Using `AnimationNodeOneShot` for high-priority reactive animations like recoil, blinks, and hit reactions.

### [dynamic_timescale_control.gd](scripts/dynamic_timescale_control.gd)
Runtime manipulation of playback speed for bullet-time effects or movement haste multipliers.

### [advanced_transition_masking.gd](scripts/advanced_transition_masking.gd)
Procedural bone filtering (masking) for nodes like `Add2` to separate upper/lower body animations.

### [statemachine_travel_code.gd](scripts/statemachine_travel_code.gd)
Programmatic control of `AnimationNodeStateMachinePlayback` using `travel()` and `start()`.

### [blendtree_logic_mixing.gd](scripts/blendtree_logic_mixing.gd)
Complex mixing patterns for `BlendTree` nodes to create interactive combat layers.

### [root_motion_animtree_sync.gd](scripts/root_motion_animtree_sync.gd)
Expert 3D CharacterBody motion extraction optimized specifically for `AnimationTree` nodes.

### [sync_group_layering.gd](scripts/sync_group_layering.gd)
Using Sync Groups to keep multi-layered animations (e.g. walk and reload) perfectly aligned.

### [nested_tree_architecture.gd](scripts/nested_tree_architecture.gd)
Pattern for managing hierarchical State Machines and nested node parameter paths.

### [runtime_tree_debugging.gd](scripts/runtime_tree_debugging.gd)
Interactive tool for visualizing current states, transition paths, and blend values in real-time.

---

## Core Concepts

### AnimationTree Structure

```
AnimationTree (node)
  ├─ Root (assigned in editor)
  │   ├─ StateMachine (common)
  │   ├─ BlendTree (layering)
  │   └─ BlendSpace (directional)
  └─ anim_player: NodePath → points to AnimationPlayer
```

### Parameter Access

```gdscript
# Set parameters using string paths
$AnimationTree.set("parameters/StateMachine/transition_request", "run")
$AnimationTree.set("parameters/Movement/blend_position", Vector2(1, 0))

# Get current state
var current_state = $AnimationTree.get("parameters/StateMachine/current_state")
```

---

## StateMachine Pattern

### Basic Setup

```gdscript
# Scene structure:
# CharacterBody2D
#   ├─ AnimationPlayer (has: idle, walk, run, jump, land)
#   └─ AnimationTree
#       └─ Root: AnimationNodeStateMachine

# StateMachine nodes (created in AnimationTree editor):
# - Idle (AnimationNode referencing "idle")
# - Walk (AnimationNode referencing "walk")
# - Run (AnimationNode referencing "run")
# - Jump (AnimationNode referencing "jump")
# - Land (AnimationNode referencing "land")

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/StateMachine/playback")

func _ready() -> void:
    anim_tree.active = true

func _physics_process(delta: float) -> void:
    var velocity := get_velocity()
    
    # State transitions based on gameplay
    if is_on_floor():
        if velocity.length() < 10:
            state_machine.travel("Idle")
        elif velocity.length() < 200:
            state_machine.travel("Walk")
        else:
            state_machine.travel("Run")
    else:
        if velocity.y < 0:  # Rising
            state_machine.travel("Jump")
        else:  # Falling
            state_machine.travel("Land")
```

### Transition Conditions (Advance Expressions)

```gdscript
# In AnimationTree editor:
# Add transition from Idle → Walk
# Set "Advance Condition" to "is_walking"

# In code:
anim_tree.set("parameters/conditions/is_walking", true)

# Transition fires automatically when condition becomes true
# Useful for event-driven transitions (hurt, dead, etc.)

# Example: Damage transition
anim_tree.set("parameters/conditions/is_damaged", false)  # Reset each frame

func take_damage() -> void:
    anim_tree.set("parameters/conditions/is_damaged", true)
    # Transition to "Hurt" state fires immediately
```

### Auto-Advance (Combo Chains)

```gdscript
# In AnimationTree editor:
# Transition from Attack1 → Attack2
# Enable "Auto Advance" (no condition needed)

# Code:
state_machine.travel("Attack1")
# Attack1 animation plays
# When Attack1 finishes, automatically transitions to Attack2
# When Attack2 finishes, transitions to Idle (next auto-advance)

# Useful for:
# - Attack combos
# - Death → Respawn
# - Cutscene sequences
```

---

## BlendSpace2D (Directional Movement)

### 8-Way Movement

```gdscript
# Create BlendSpace2D in AnimationTree editor:
# - Add animations at positions:
#   - (0, -1): walk_up
#   - (0, 1): walk_down
#   - (-1, 0): walk_left
#   - (1, 0): walk_right
#   - (-1, -1): walk_up_left
#   - (1, -1): walk_up_right
#   - (-1, 1): walk_down_left
#   - (1, 1): walk_down_right
#   - (0, 0): idle (center)

# In code:
func _physics_process(delta: float) -> void:
    var input := Input.get_vector("left", "right", "up", "down")
    
    # Set blend position (AnimationTree interpolates between animations)
    anim_tree.set("parameters/Movement/blend_position", input)
    
    # BlendSpace2D automatically blends animations based on input
    # input = (0.5, -0.5) → blends walk_right and walk_up
```

### BlendSpace1D (Speed Blending)

```gdscript
# For walk → run transitions
# Create BlendSpace1D:
#   - Position 0.0: walk
#   - Position 1.0: run

func _physics_process(delta: float) -> void:
    var speed := velocity.length()
    var max_speed := 400.0
    var blend_value := clamp(speed / max_speed, 0.0, 1.0)
    
    anim_tree.set("parameters/SpeedBlend/blend_position", blend_value)
    # Smoothly blends from walk → run as speed increases
```

---

## BlendTree (Layered Animations)

### Add Upper Body Animation

```gdscript
# Problem: Want to aim gun while walking
# Solution: Blend upper body (aim) with lower body (walk)

# In AnimationTree editor:
# Root → BlendTree
#   ├─ Walk (lower body animation)
#   ├─ Aim (upper body animation)
#   └─ Add2 node (combines them)
#       - Inputs: Walk, Aim
#       - filter_enabled: true
#       - Filters: Only enable upper body bones for Aim

# Code:
# No code needed! BlendTree auto-combines
# Just ensure animations are assigned
```

### Blend2 (Crossfade)

```gdscript
# Blend between two animations dynamically
# Root → BlendTree
#   └─ Blend2
#       ├─ Input A: idle
#       └─ Input B: attack

# Code:
var blend_amount := 0.0

func _process(delta: float) -> void:
    # Gradually blend from idle → attack
    blend_amount += delta
    blend_amount = clamp(blend_amount, 0.0, 1.0)
    
    anim_tree.set("parameters/IdleAttackBlend/blend_amount", blend_amount)
    # 0.0 = 100% idle
    # 0.5 = 50% idle, 50% attack
    # 1.0 = 100% attack
```

---

## Root Motion with AnimationTree

```gdscript
# Enable in AnimationTree
anim_tree.root_motion_track = NodePath("CharacterBody3D/Skeleton3D:Root")

func _physics_process(delta: float) -> void:
    # Get root motion
    var root_motion := anim_tree.get_root_motion_position()
    
    # Apply to character (not velocity!)
    global_position += root_motion.rotated(rotation.y)
    
    # For CharacterBody3D with move_and_slide:
    velocity = root_motion / delta
    move_and_slide()
```

---

## Advanced Patterns

### Sub-StateMachines

```gdscript
# Nested state machines for complex behavior
# Root → StateMachine
#   ├─ Grounded (Sub-StateMachine)
#   │   ├─ Idle
#   │   ├─ Walk
#   │   └─ Run
#   └─ Airborne (Sub-StateMachine)
#       ├─ Jump
#       ├─ Fall
#       └─ Glide

# Access nested states:
var sub_state = anim_tree.get("parameters/Grounded/playback")
sub_state.travel("Run")
```

### Time Scale (Slow Motion)

```gdscript
# Slow down specific animation without affecting others
anim_tree.set("parameters/TimeScale/scale", 0.5)  # 50% speed

# Useful for:
# - Bullet time
# - Hurt/stun effects
# - Charge-up animations
```

### Sync Between Animations

```gdscript
# Problem: Switching from walk → run causes foot slide
# Solution: Use "Sync" on transition

# In AnimationTree editor:
# Transition: Walk → Run
# Enable "Sync" checkbox

# Godot automatically syncs animation playback positions
# Feet stay grounded during transition
```

---

## Debugging AnimationTree

### Print Current State

```gdscript
func _process(delta: float) -> void:
    var current_state = anim_tree.get("parameters/StateMachine/current_state")
    print("Current state: ", current_state)
    
    # Print blend position
    var blend_pos = anim_tree.get("parameters/Movement/blend_position")
    print("Blend position: ", blend_pos)
```

### Common Issues

```gdscript
# Issue: Animation not playing
# Solution:
if not anim_tree.active:
    anim_tree.active = true

# Issue: Transition not working
# Check:
# 1. Is advance_condition set?
# 2. Is transition priority correct?
# 3. Is auto_advance enabled unintentionally?

# Issue: Blend not smooth
# Solution: Increase transition xfade_time (0.1 - 0.3s)
```

---

## Performance Optimization

### Disable When Not Needed

```gdscript
# AnimationTree is expensive
# Disable for off-screen entities
extends VisibleOnScreenNotifier3D

func _ready() -> void:
    screen_exited.connect(_on_screen_exited)
    screen_entered.connect(_on_screen_entered)

func _on_screen_exited() -> void:
    $AnimationTree.active = false

func _on_screen_entered() -> void:
    $AnimationTree.active = true
```

---

## Decision Tree: When to Use AnimationTree

| Feature | AnimationPlayer Only | AnimationTree |
|---------|---------------------|---------------|
| Simple state swap | ✅ play("idle") | ❌ Overkill |
| Directional movement | ❌ Complex | ✅ BlendSpace2D |
| State machine (5+ states) | ❌ Messy code | ✅ StateMachine |
| Layered animations | ❌ Manual blending | ✅ BlendTree |
| Root motion | ✅ Possible | ✅ Built-in |
| Transition blending | ❌ Manual | ✅ Auto |

**Use AnimationTree for**: Complex characters with 5+ states, directional movement, layered animations
**Use AnimationPlayer for**: Simple animations, UI, cutscenes, props


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)

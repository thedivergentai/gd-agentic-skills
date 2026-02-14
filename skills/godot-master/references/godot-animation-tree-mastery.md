> [!NOTE]
> **Resource Context**: This module provides expert patterns for **AnimationTree Mastery**. Accessed via Godot Master.

# AnimationTree Mastery

Expert guidance for Godot's advanced animation blending and state machines.

## Available Scripts

### [nested_state_machine.gd](../scripts/godot-animation-tree-mastery_nested_state_machine.gd)
Hierarchical state machine pattern. Shows travel() between sub-states and deep parameter paths.

### [skeleton_ik_lookat.gd](../scripts/godot-animation-tree-mastery_skeleton_ik_lookat.gd)
Procedural IK for head-tracking. Drives SkeletonModifier3D look-at parameters from AnimationTree.


## NEVER Do

- **NEVER call play() on AnimationPlayer when using AnimationTree** — Use the tree's parameters instead to avoid control conflicts.
- **NEVER forget to set active = true** — The node is inactive by default in the Inspector or via code.
- **NEVER use absolute paths for parameters** — Always use relative paths starting from "parameters/".
- **NEVER use BlendSpace2D for non-directional blending** — Use BlendSpace1D or simple Blend2 nodes for speed or single-axis transitions.

---

## StateMachine Patterns

### Playback Control
```gdscript
@onready var state_machine: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/StateMachine/playback")

func _physics_process(delta: float) -> void:
    if is_on_floor():
        state_machine.travel("Idle")
    else:
        state_machine.travel("Jump")
```

### Advance Conditions
Use boolean parameters set from code to trigger transitions at specific moments (e.g., `is_dead`, `is_hurt`).
```gdscript
anim_tree.set("parameters/conditions/is_damaged", true)
```

## BlendSpace2D (Movement)
Map directional input to 2D blend positions for 8-way movement blending:
```gdscript
var input := Input.get_vector("left", "right", "up", "down")
anim_tree.set("parameters/Movement/blend_position", input)
```

## BlendTree (Layering)
Use `Add2` or `Blend2` nodes with **Filters** enabled to combine animations on different parts of the skeleton (e.g., walking on lower body + aiming on upper body).

## Decision Matrix: AnimationPlayer vs AnimationTree

| Feature | AnimationPlayer | AnimationTree |
|---------|-----------------|---------------|
| Simple state swap | ✅ Recommended | ❌ Overkill |
| Directional movement | ❌ Complex | ✅ Recommended |
| Complex logic (5+ states) | ❌ Messy | ✅ Recommended |
| Layered animations | ❌ Limited | ✅ Recommended |

## Reference
- [Godot Docs: AnimationTree](https://docs.godotengine.org/en/stable/classes/class_animationtree.html)
- [Godot Docs: BlendSpace2D](https://docs.godotengine.org/en/stable/classes/class_animationnodeblendspace2d.html)

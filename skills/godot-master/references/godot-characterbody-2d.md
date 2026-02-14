> [!NOTE]
> **Resource Context**: This module provides expert patterns for **CharacterBody2D**. Accessed via Godot Master.

# CharacterBody2D Implementation

Expert guidance for player-controlled 2D movement using Godot's physics system.

## Available Scripts

### [expert_physics_2d.gd](../scripts/godot-characterbody-2d_expert_physics_2d.gd)
Complete platformer movement with coyote time, jump buffering, smooth acceleration/friction, and sub-pixel stabilization.

### [dash_controller.gd](../scripts/godot-characterbody-2d_dash_controller.gd)
Frame-perfect dash with I-frames, cooldown, and momentum preservation.

### [wall_jump_controller.gd](../scripts/godot-characterbody-2d_wall_jump_controller.gd)
Wall slide, cling, and directional wall jump with auto-correction.


## NEVER Do

- **NEVER multiply velocity by delta when using `move_and_slide()`** — `move_and_slide()` already accounts for delta time.
- **NEVER forget to check `is_on_floor()` before jumping** — Unless you're implementing a double jump or coyote time deliberately.
- **NEVER use `velocity.x = direction * SPEED` without friction** — The character will slide infinitely. Use `move_toward` with a friction value.
- **NEVER set `velocity.y` to a fixed value when falling** — Use `velocity.y += gravity * delta` to accumulate fall speed correctly.
- **NEVER use `floor_snap_length` > 16px** — Large values can cause the character to "snap" to walls or slopes unexpectedly.

---

## Pro Platformer Patterns

### Coyote Time & Jump Buffering
Implement a short timer after leaving a ledge (coyote time) and a short buffer for jump inputs before landing (jump buffering) to make controls feel more responsive and forgiving.

### Variable Jump Height
Reduce vertical velocity when the jump button is released mid-jump:
```gdscript
if Input.is_action_just_released("jump") and velocity.y < 0:
    velocity.y *= 0.5
```

## Top-Down Movement
For 8-directional movement, use `Input.get_vector()` and normalize the result for consistent speed:
```gdscript
var input_vector := Input.get_vector("left", "right", "up", "down")
velocity = velocity.move_toward(input_vector * SPEED, ACCEL * delta)
```

## Slope Handling
Adjust `floor_max_angle` and `floor_snap_length` to prevent sliding or stuttering on inclines.

## Reference
- [Godot Docs: CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html)
- [Godot Docs: Using CharacterBody2D](https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html)

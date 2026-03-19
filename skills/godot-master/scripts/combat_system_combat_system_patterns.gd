# combat_system_patterns.gd
extends Node

# 1. Safe Duck-Typing for Damage
# EXPERT NOTE: Safely test if a target can receive damage without needing to know its exact class.
func _on_hitbox_impact(target: Node) -> void:
    if target.has_method(&"take_damage"):
        target.call(&"take_damage", 50)

# 2. Safe Type Casting
# EXPERT NOTE: Use the 'as' keyword. If the cast fails, it securely returns null instead of crashing.
func _on_area_body_entered(body: Node2D) -> void:
    var player := body as CharacterBody2D
    if player and player.has_method(&"die"):
        player.call(&"die")

# 3. Decoupling UI via Signal Binding
# EXPERT NOTE: Connect specific combat data to the UI using Callables and bound arguments.
signal combat_log_requested(source: String, amount: int)
func setup_combat_listeners(entity: Node) -> void:
    # Binds "Sword" and 100 to the signal every time it fires
    entity.connect(&"on_hit", _log_damage.bind("Sword", 100))

func _log_damage(_src: String, _amt: int) -> void: pass

# 4. Custom Stat Resources
# EXPERT NOTE: Build data containers explicitly for the Godot Inspector to keep logic clean.
# class_name CombatStats extends Resource
# @export var max_health: int = 100
# @export var defense: int = 5

# 5. Exporting Enum Bit Flags
# EXPERT NOTE: Allow designers to set multiple elemental damage types seamlessly in the Inspector.
@export_flags("Fire", "Ice", "Poison", "Electric") var damage_types: int = 0

# 6. Interruptible Hitstun Tweens
# EXPERT NOTE: Cache tweens to allow consecutive hits to safely override and restart animations.
var _hit_tween: Tween
func apply_hitstun_vfx(target: CanvasItem) -> void:
    if _hit_tween: _hit_tween.kill() # Cancel previous if still running
    _hit_tween = create_tween()
    _hit_tween.tween_property(target, "modulate", Color.RED, 0.1)
    _hit_tween.tween_property(target, "modulate", Color.WHITE, 0.1)

# 7. Nodeless AoE Shape Casting
# EXPERT NOTE: Bypass Area nodes for an instantaneous, C++ powered physics overlap check.
func check_explosion_at(pos: Vector3, radius: float) -> Array:
    var query := PhysicsShapeQueryParameters3D.new()
    var shape := SphereShape3D.new()
    shape.radius = radius
    query.shape_rid = shape.get_rid()
    query.transform = Transform3D.IDENTITY.translated(pos)
    # Perform direct space state check
    return get_world_3d().direct_space_state.intersect_shape(query)

# 8. Unbinding Native Signal Variables
# EXPERT NOTE: Safely ignore default emitted arguments if the target method requires none.
func connect_attack_button(btn: Button) -> void:
    # pressed normally suggests passing 0 args, but unbind(1) is useful if a signal sends data you don't want
    btn.pressed.connect(_execute_swing.unbind(1))

func _execute_swing() -> void: pass

# 9. Disabling Hitboxes Safely
# EXPERT NOTE: Defer disabling collisions so the physics engine isn't disrupted mid-step.
func disable_hitbox(collider: CollisionShape2D) -> void:
    collider.set_deferred(&"disabled", true)

# 10. Frame-Perfect Animation Syncing
# EXPERT NOTE: Override process modes for strict combat determinism (syncing with physics).
func setup_combat_animator(mixer: AnimationMixer) -> void:
    mixer.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS

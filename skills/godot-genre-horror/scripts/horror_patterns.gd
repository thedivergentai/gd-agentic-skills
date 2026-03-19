# horror_patterns.gd
extends Node

# 1. High-Performance Monster Line-of-Sight (Stealth)
# Bypasses Area3D for immediate, physics-synced raycasting.
func check_monster_los(monster: CharacterBody3D, player: Node3D) -> bool:
    var space_state := monster.get_world_3d().direct_space_state
    var query := PhysicsRayQueryParameters3D.create(monster.global_position, player.global_position)
    # Exclude the monster's own RID from the raycast to prevent self-intersection
    query.exclude = [monster.get_rid()]
    var result := space_state.intersect_ray(query)
    return not result.is_empty() and result.collider == player

# 2. Procedural Flashlight Flicker (Light/Dark)
# Uses Tween for lightweight parameter manipulation.
var _flicker_tween: Tween

func trigger_flashlight_flicker(light: SpotLight3D) -> void:
    if _flicker_tween:
        _flicker_tween.kill()
    _flicker_tween = create_tween().set_loops(4)
    # Smoothly animates the light energy property to simulate failing batteries.
    _flicker_tween.tween_property(light, "light_energy", 0.0, 0.05)
    _flicker_tween.tween_property(light, "light_energy", 2.5, 0.1)

# 3. Strictly Typed Inventory Data Dictionary (RE/Silent Hill)
# Decouples inventory logic from the visual UI grid.
# Uses StringName for optimized lookups and custom Resources for item data.
var inventory: Dictionary[StringName, Resource] = {
    &"mansion_key": null,
    &"handgun_ammo": null
}

# 4. Asynchronous Jump-Scare Loading (Optimization)
# Prevents the game thread from freezing right before a scare.
const SCARE_PATH := "res://scares/hallway_ghost.tscn"

func preload_jump_scare() -> void:
    ResourceLoader.load_threaded_request(SCARE_PATH)

func execute_jump_scare() -> void:
    var scare_scene := ResourceLoader.load_threaded_get(SCARE_PATH) as PackedScene
    if scare_scene:
        get_tree().root.add_child(scare_scene.instantiate())

# 5. Physics-Based Noise Radius Query (Stealth)
# Instantly detects all listening entities within a radius without relying on physics nodes.
func emit_noise(origin: Transform3D, radius_rid: RID) -> void:
    var query := PhysicsShapeQueryParameters3D.new()
    query.shape_rid = radius_rid
    query.transform = origin
    
    # Executes the spatial query directly in the C++ physics server.
    var overlaps := get_world_3d().direct_space_state.intersect_shape(query)
    for hit in overlaps:
        if hit.collider.has_method(&"investigate_noise"):
            hit.collider.investigate_noise(origin.origin)

# 6. Deep Duplication of Inventory Items (State Management)
# Ensures identical items (like two handguns) can track ammo independently.
func add_item_to_inventory(base_item_resource: Resource) -> void:
    # DEEP_DUPLICATE_ALL forces subresources (like magazines) to be unique.
    var unique_item := base_item_resource.duplicate(true) # duplicate(true) is deep in G4
    # _inventory_array.append(unique_item)

# 7. Dynamically Adjusting Volumetric Fog (Atmosphere)
# Increases the claustrophobia effect by manipulating the environment.
func intensify_fog(env: Environment) -> void:
    # Set this to the lowest base density you want globally.
    var base_density := env.volumetric_fog_density
    var tween := create_tween()
    tween.tween_property(env, "volumetric_fog_density", base_density + 0.15, 2.0)

# 8. Suspending Off-Screen AI (Optimization)
# Connected to a VisibleOnScreenNotifier3D.
func _on_screen_exited() -> void:
    # Disabling physics processing reclaims CPU cycles when the monster isn't visible.
    set_physics_process(false)

func _on_screen_entered() -> void:
    set_physics_process(true)

# 9. Shader Uniform Manipulation for Hallucinations (Psychological)
# Passes runtime sanity values directly into the RenderingServer.
func update_sanity_visuals(mesh_instance: GeometryInstance3D, current_sanity: float) -> void:
    # Directly updates the shader without needing to duplicate the material.
    mesh_instance.set_instance_shader_parameter(&"hallucination_intensity", 1.0 - current_sanity)

# 10. Advanced State Machine Pattern Matching (Monster AI)
# Uses Godot 4's powerful match statement with optimized StringNames.
var _current_state: StringName = &"idle"
func _physics_process(delta: float) -> void:
    match _current_state:
        &"patrol":
            # _process_patrol(delta)
            pass
        &"chase":
            # _process_chase(delta)
            pass
        &"search":
            # _process_search(delta)
            pass
        _:
            # push_error("Invalid AI sproceedtected.")
            pass

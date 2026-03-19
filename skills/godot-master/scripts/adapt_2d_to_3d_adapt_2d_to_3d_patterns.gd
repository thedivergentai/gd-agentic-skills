# adapt_2d_to_3d_patterns.gd
extends Node

# 1. Projecting 2D UI into 3D Space
# EXPERT NOTE: Use a SubViewport inside a Sprite3D for interactive "Diegetic" UI.
func project_pixel_to_world_ui(viewport: SubViewport, sprite: Sprite3D) -> void:
    sprite.texture = viewport.get_texture()
    # Required for transparency in 3D
    sprite.transparent = true
    sprite.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

# 2. 2D Billboard in 3D Scene
# EXPERT NOTE: Sprite3D is the bridge. billboard_mode creates the "DOOM" style look.
func create_billboard_sprite(tex: Texture2D) -> Sprite3D:
    var s := Sprite3D.new()
    s.texture = tex
    s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    return s

# 3. Raycasting from 2D Mouse to 3D Physics
# EXPERT NOTE: Essential for "Point and Click" in a 3D environment.
func get_3d_mouse_pos(camera: Camera3D) -> Vector3:
    var mouse_pos := get_viewport().get_mouse_position()
    var ray_origin := camera.project_ray_origin(mouse_pos)
    var ray_dir := camera.project_ray_normal(mouse_pos)
    var ray_query := PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_dir * 1000)
    var result := camera.get_world_3d().direct_space_state.intersect_ray(ray_query)
    
    return result.position if result else Vector3.ZERO

# 4. CanvasLayer Layering in 3D
# EXPERT NOTE: Keep UI independent of 3D FOV by putting it on a high CanvasLayer.
func setup_overlay_ui(ui_node: Control) -> void:
    var canvas := CanvasLayer.new()
    canvas.layer = 100
    add_child(canvas)
    canvas.add_child(ui_node)

# 5. Using 2D Particles in 3D (SubViewportMesh)
# EXPERT NOTE: Sometimes 2D particles look better. Wrap them in a plane mesh.
func create_2d_fx_in_3d(fx_scene: PackedScene) -> MeshInstance3D:
    var mesh := MeshInstance3D.new()
    mesh.mesh = QuadMesh.new() # Default 1x1 plane
    # Material set to show SubViewport would go here
    return mesh

# 6. Global Illumination for 2D Assets
# EXPERT NOTE: Sprite3D can receive 3D light/shadows if shaded mode is enabled.
func enable_shaded_sprites(sprite: Sprite3D) -> void:
    sprite.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
    sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

# 7. Coordinate Translation (3D World to 2D Screen)
# EXPERT NOTE: Place "floating" health bars or name tags over 3D units.
func position_ui_over_target(camera: Camera3D, target: Node3D, ui_element: Control) -> void:
    if camera.is_position_behind(target.global_position):
        ui_element.visible = false
    else:
        ui_element.visible = true
        ui_element.position = camera.unproject_position(target.global_position)

# 8. Handling Resolution Mismatch
# EXPERT NOTE: 2D pixel-art in a high-res 3D world needs content_scale interpolation.
func setup_mixed_resolution() -> void:
    get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
    get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND

# 9. Pixel-Perfect 3D Rendering (Retro Look)
# EXPERT NOTE: Render 3D at a lower resolution then upscale to a 2D viewport.
func setup_retro_render(sub_viewport: SubViewport) -> void:
    sub_viewport.size = Vector2i(320, 180)
    sub_viewport.texture_filter = Viewport.TEXTURE_FILTER_NEAREST

# 10. Mixing 2D and 3D Input
# EXPERT NOTE: Ensure UI consumes events before the 3D raycast triggers logic.
func _input(event: InputEvent) -> void:
    if get_viewport().gui_get_focus_owner():
        return # UI is handling this
    # 3D interaction logic...

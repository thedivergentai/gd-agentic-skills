extends RayCast3D

## Debug tool to visualize RayCast3D hit points and normals.
## Usage: Enable 'enabled' property and 'visible'.

@export var line_color: Color = Color.RED
@export var hit_color: Color = Color.GREEN
@export var line_width: float = 2.0
@export var always_show: bool = false # Show even if not colliding

var _mesh_instance: MeshInstance3D
var _immediate_mesh: ImmediateMesh
var _material: StandardMaterial3D

func _ready() -> void:
    _setup_visuals()

func _setup_visuals() -> void:
    _mesh_instance = MeshInstance3D.new()
    _mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(_mesh_instance)
    
    _immediate_mesh = ImmediateMesh.new()
    _mesh_instance.mesh = _immediate_mesh
    
    _material = StandardMaterial3D.new()
    _material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
    _material.vertex_color_use_as_albedo = true
    _mesh_instance.set_surface_override_material(0, _material)

func _process(_delta: float) -> void:
    if not is_inside_tree(): return
    
    _immediate_mesh.clear_surfaces()
    
    if not enabled and not always_show:
        return
        
    var start_pos := Vector3.ZERO
    var end_pos := target_position
    
    force_raycast_update()
    
    if is_colliding():
        end_pos = to_local(get_collision_point())
        _draw_line(start_pos, end_pos, hit_color)
        # Draw normal
        var normal := get_collision_normal()
        _draw_line(end_pos, end_pos + to_local(global_position + normal) - to_local(global_position), Color.AQUA)
    else:
        if always_show:
            _draw_line(start_pos, end_pos, line_color)

func _draw_line(from: Vector3, to: Vector3, color: Color) -> void:
    _immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
    _immediate_mesh.surface_set_color(color)
    _immediate_mesh.surface_add_vertex(from)
    _immediate_mesh.surface_add_vertex(to)
    _immediate_mesh.surface_end()

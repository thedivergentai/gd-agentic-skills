# skills/adapt-2d-to-3d/scripts/vector_mapping.gd
class_name VectorMapping

## Vector Mapping Expert Pattern
## Static utility for converting vectors between 2D and 3D spaces.
## Common Rule: 2D Y (Down) -> 3D Z (Back/South)
##              2D X (Right) -> 3D X (Right/East)

# 2D -> 3D (XZ Plane)
# Useful for movement: Input(x, y) -> Velocity(x, 0, z)
static func v2_to_v3_xz(v2: Vector2, y_height: float = 0.0) -> Vector3:
    return Vector3(v2.x, y_height, v2.y)

# 2D -> 3D (XY Plane)
# Useful for UI projection or side-scrollers
static func v2_to_v3_xy(v2: Vector2, z_depth: float = 0.0) -> Vector3:
    return Vector3(v2.x, v2.y, z_depth)

# 3D -> 2D (XZ Plane)
# Useful for minimaps (ignoring height)
static func v3_to_v2_xz(v3: Vector3) -> Vector2:
    return Vector2(v3.x, v3.z)

# 3D -> 2D (XY Plane)
# Useful for side projections
static func v3_to_v2_xy(v3: Vector3) -> Vector2:
    return Vector2(v3.x, v3.y)

# Directional Mapping
# Remaps a 2D angle to a 3D Y-axis rotation
static func angle_2d_to_rotation_y(angle_radians: float) -> float:
    # 2D: 0 is Right, PI/2 is Down
    # 3D: 0 is -Z (Forward)? Depends on convention.
    # Godot 3D: -Z is Forward.
    # If 2D Up (Start) maps to 3D Forward:
    # 2D Angle needs -PI/2 offset usually.
    return -angle_radians

## EXPERT USAGE:
## var move_3d = VectorMapping.v2_to_v3_xz(input_vector)

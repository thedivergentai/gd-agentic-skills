# godot-master/scripts/3d_lighting_day_night_cycle.gd
extends DirectionalLight3D

## Day/Night Cycle (Expert Pattern)
## Controls sun position, color temperature, and ambient light based on time.
## Includes realistic color curves for Dawn/Dusk.

class_name DayNightCycle

@export_range(0.0, 24.0) var time_of_day: float = 12.0
@export var day_duration_seconds: float = 600.0 # 10 minutes real time
@export var sun_gradient: Gradient
@export var ambient_gradient: Gradient
@export var environment: Environment

var time_multiplier: float = 1.0

func _ready() -> void:
    if not sun_gradient:
        _setup_default_gradients()
    if not environment:
        # Try to find world environment
        var env_node = get_tree().get_first_node_in_group("world_environment")
        if env_node: environment = env_node.environment

func _process(delta: float) -> void:
    time_of_day += (delta / day_duration_seconds) * 24.0 * time_multiplier
    if time_of_day >= 24.0:
        time_of_day -= 24.0
        
    _update_sun()

func _update_sun() -> void:
    # 0 = Midnight, 6 = Sunrise, 12 = Noon, 18 = Sunset
    
    # Rotation (Simple Axis Rotation)
    # Mapping 0-24 to -180 to 180 degrees logic
    # Noon (12) should be -90 degrees pitch (straight down) if using X rotation?
    # Godot Default: Y-up. X-rotation -90 is looking down.
    
    var hour_angle = (time_of_day - 12.0) * 15.0 # 15 degrees per hour
    rotation_degrees.x = -90.0 + abs(hour_angle) # Logic for arc?
    # Better: Full rotation around X
    rotation_degrees.x = (time_of_day - 6.0) * 15.0 - 90.0 
    # At 6am: 0 * 15 - 90 = -90? No.
    # At 6am, we want horizon (0). 
    # At 12pm, we want down (-90).
    # Value: (6-6)*15 - 90 = -90. Wait.
    # Let's map standard: 
    # 6am = -180 (Rising?) 
    # Simple:
    # 0.0 (Midnight) -> -90 (Up/Down?)
    
    # Standard Cycle:
    var angle = remap(time_of_day, 0.0, 24.0, -90.0, 270.0)
    rotation_degrees.x = angle
    
    # Color & Energy
    var sample_pos = time_of_day / 24.0
    if sun_gradient:
        light_color = sun_gradient.sample(sample_pos)
        
    # Intensity (Fade at night)
    if time_of_day < 5.0 or time_of_day > 19.0:
        light_energy = 0.0
        shadow_enabled = false
    else:
        # Fade in/out
        var fade = 1.0
        if time_of_day < 6.0: fade = time_of_day - 5.0
        if time_of_day > 18.0: fade = 19.0 - time_of_day
        light_energy = clamp(fade, 0.0, 1.0)
        shadow_enabled = true
        
    # Ambient
    if environment and ambient_gradient:
        environment.ambient_light_color = ambient_gradient.sample(sample_pos)

func _setup_default_gradients() -> void:
    sun_gradient = Gradient.new()
    sun_gradient.add_point(0.0, Color(0.1, 0.1, 0.3)) # Night
    sun_gradient.add_point(0.25, Color(1.0, 0.6, 0.3)) # Dawn
    sun_gradient.add_point(0.5, Color(1.0, 1.0, 0.95)) # Noon
    sun_gradient.add_point(0.75, Color(1.0, 0.5, 0.2)) # Dusk
    sun_gradient.add_point(1.0, Color(0.1, 0.1, 0.3)) # Night

## EXPERT USAGE:
## Attach to DirectionalLight3D. Assign WorldEnvironment.
## Customize gradients for alien worlds.

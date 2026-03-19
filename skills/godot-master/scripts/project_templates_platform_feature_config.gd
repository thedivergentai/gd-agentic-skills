class_name PlatformFeatureConfig
extends Node

## Use Godot's built-in Feature Tags to conditionally execute logic.
## Strips server logic from client builds and manages mobile-specific overrides.

@export var mobile_max_fps: int = 60
@export var desktop_max_fps: int = 144

func _ready() -> void:
	_apply_platform_overrides()

func _apply_platform_overrides() -> void:
	if OS.has_feature("dedicated_server"):
		# Start headless multiplayer server
		_initialize_server_logic()
	elif OS.has_feature("mobile"):
		# Lower rendering overhead for Android/iOS
		_apply_mobile_profile()
	elif OS.has_feature("pc"):
		_apply_desktop_profile()

func _apply_mobile_profile() -> void:
	# Disable heavy post-processing
	get_viewport().use_taa = false
	Engine.max_fps = mobile_max_fps

func _apply_desktop_profile() -> void:
	Engine.max_fps = desktop_max_fps

func _initialize_server_logic() -> void:
	# Disable visual processing in headless mode
	set_process(false)
	set_physics_process(true)

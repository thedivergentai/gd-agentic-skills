class_name ThemeManager extends Node

signal theme_changed(is_dark_mode: bool)

@export var dark_theme: Theme
@export var light_theme: Theme
@export var control_root: Control

var is_dark_mode: bool = true

func _ready() -> void:
    apply_theme()

func toggle_theme() -> void:
    is_dark_mode = not is_dark_mode
    apply_theme()
    theme_changed.emit(is_dark_mode)

func apply_theme() -> void:
    if not control_root:
        return
        
    if is_dark_mode:
        control_root.theme = dark_theme
    else:
        control_root.theme = light_theme

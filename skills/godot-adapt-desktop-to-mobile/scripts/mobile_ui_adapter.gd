# skills/adapt-desktop-to-mobile/scripts/mobile_ui_adapter.gd
extends CanvasLayer

## Mobile UI Adapter Expert Pattern
## Auto-detects mobile platform and creates touch controls / scales UI.

class_name MobileUIAdapter

@export var virtual_joystick_scene: PackedScene
@export var touch_button_group: Control # Container for right-side buttons

func _ready() -> void:
	if _is_mobile():
		_enable_mobile_controls()
		_scale_ui_elements()
	else:
		_disable_mobile_controls()

func _is_mobile() -> bool:
	return OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")

func _enable_mobile_controls() -> void:
	if virtual_joystick_scene:
		var stick = virtual_joystick_scene.instantiate()
		add_child(stick)
		# Position bottom-left
		stick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		stick.position += Vector2(50, -50) # Margin
	
	if touch_button_group:
		touch_button_group.show()

func _disable_mobile_controls() -> void:
	if touch_button_group:
		touch_button_group.hide()

func _scale_ui_elements() -> void:
	# Iterate over specific groups to scale up for touch
	var buttons = get_tree().get_nodes_in_group("touch_interactive")
	
	for btn in buttons:
		if btn is Control:
			# Ensure min 44pt (approx 88px on high DPI)
			var min_size = 88.0
			if btn.custom_minimum_size.x < min_size:
				btn.custom_minimum_size.x = min_size
			if btn.custom_minimum_size.y < min_size:
				btn.custom_minimum_size.y = min_size

## EXPERT USAGE:
## Add to Main Scene. Assign Virtual Joystick scene. 
## Group small buttons as "touch_interactive" to auto-scale them.

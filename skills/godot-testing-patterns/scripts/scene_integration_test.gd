# scene_integration_test.gd
# Testing full scene interaction
extends GdUnitTestSuite

# EXPERT NOTE: Integration tests ensure that nodes in 
# a scene interact correctly after .instantiate().

func test_ui_button_press():
	var scene = spy("res://menu.tscn")
	var button = scene.get_node("StartButton")
	
	# Simulate user interaction
	button.emit_signal("pressed")
	
	assert_that(scene.is_game_started).is_true()
	scene.free()

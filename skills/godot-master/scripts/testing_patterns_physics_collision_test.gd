# physics_collision_test.gd
# Verifying world intersections
extends GdUnitTestSuite

# EXPERT NOTE: Automated physics tests ensure that 
# changes to collision layers don't break gameplay.

func test_wall_collision():
	var ball = preload("res://ball.tscn").instantiate()
	var wall = preload("res://wall.tscn").instantiate()
	
	add_child(ball)
	add_child(wall)
	
	ball.global_position = Vector2(0, 0)
	wall.global_position = Vector2(5, 0)
	
	await yield_frames(5) # Give physics time to resolve
	
	assert_that(ball.is_on_wall()).is_true()

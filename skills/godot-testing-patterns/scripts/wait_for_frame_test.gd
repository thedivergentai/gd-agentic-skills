# wait_for_frame_test.gd
# Testing asynchronous behavior
extends GdUnitTestSuite

# EXPERT NOTE: Use await yield_signal() or yield_frames() 
# in GdUnit4 to test logic that spans multiple frames.

func test_delayed_respawn():
	var player = Player.new()
	player.die()
	
	# Wait for the respawn timer to finish
	await yield_seconds(2.0)
	
	assert_that(player.is_alive).is_true()
	player.free()

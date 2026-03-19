# signal_emission_test.gd
# Verifying signal behavior in tests
extends GdUnitTestSuite

# EXPERT NOTE: Verifying that signals fire correctly is 
# critical for decoupled Godot architectures.

func test_signal_fired_on_death():
	var player = Player.new()
	var monitor = monitor_signals(player)
	
	player.health = 0
	player.check_death()
	
	verify(monitor).is_emitted("died")
	player.free()

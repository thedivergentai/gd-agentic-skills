# basic_unit_test.gd
# Minimal GdUnit4 test structure
extends GdUnitTestSuite

# EXPERT NOTE: In GdUnit4, use verify() and assert_that() 
# for readable, robust unit testing of logic scripts.

func test_arithmetic_logic():
	assert_that(1 + 1).is_equal(2)
	assert_that("Godot").is_not_empty()

func test_player_damage():
	var player = Player.new()
	player.take_damage(20)
	assert_that(player.health).is_equal(80)
	player.free()

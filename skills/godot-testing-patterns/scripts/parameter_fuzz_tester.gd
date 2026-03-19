# parameter_fuzz_tester.gd
# Stress testing systems with random data
extends Node

# EXPERT NOTE: Fuzz testing catches edge-case crashes 
# by feeding unexpected ranges into your functions.

func fuzz_test_damage_system():
	var combat = CombatLogic.new()
	for i in 100:
		var rand_dmg = randf_range(-1000, 5000)
		combat.apply(rand_dmg) # Should not crash
	combat.free()

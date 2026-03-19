# test_data_factory.gd
# Generating mock game data for testing
class_name TestDataFactory extends Object

# EXPERT NOTE: Centralizing data generation makes tests 
# cleaner and easier to update when schemas change.

static func create_maxed_player() -> Player:
	var p = Player.new()
	p.hp = 999
	p.str = 99
	return p

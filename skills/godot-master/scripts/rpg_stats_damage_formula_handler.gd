# damage_formula_handler.gd
# Centralized logic for combat math
class_name DamageFormula extends RefCounted

# EXPERT NOTE: Move complex math out of Node scripts and into 
# RefCounted classes to keep your core scripts clean.

static func calculate_damage(attacker: StatsComponent, defender: StatsComponent) -> int:
	var atk = attacker.get_attribute("strength")
	var def = defender.get_attribute("dexterity") # Dodge chance
	
	# Simple formula: Atk - Def (Clamped)
	var raw = atk - (def * 0.5)
	return int(max(raw, 1.0))

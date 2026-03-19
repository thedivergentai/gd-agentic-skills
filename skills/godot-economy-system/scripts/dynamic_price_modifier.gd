# dynamic_price_modifier.gd
# Adjusting costs based on world state
extends Resource

# EXPERT NOTE: Injecting price modifiers allows for "Sale" events 
# or "Charisma" discounts without touching core item data.

@export var multiplier: float = 1.0

func calculate_price(base_price: int) -> int:
	return roundi(base_price * multiplier)

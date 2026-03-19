# consumable_item_logic.gd
# Extensible item behavior via inheritance
class_name PotionItem extends InventoryItem

@export var heal_amount: int = 50

func use(actor: Node) -> void:
	if actor.has_method("heal"):
		actor.heal(heal_amount)
		print("Used potion: Healed ", heal_amount)

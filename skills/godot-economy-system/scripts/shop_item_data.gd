# shop_item_data.gd
# Pricing and availability for purchasables
class_name ShopItem extends Resource

# EXPERT NOTE: Shop items wrap InventoryItems with 
# pricing and stock metadata.

@export var item: InventoryItem
@export var cost: int = 100
@export var currency_id: String = "gold"
@export var initial_stock: int = -1 # -1 for infinite

var current_stock: int = 0

func _init():
	current_stock = initial_stock

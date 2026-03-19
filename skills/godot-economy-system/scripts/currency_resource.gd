# currency_resource.gd
# Specialized data container for denominations
class_name Currency extends Resource

# EXPERT NOTE: Defining Gold, Gems, and XP as Resources 
# allow for modular wallet logic and distinct UI icons.

@export var id: String = "gold"
@export var display_name: String = "Gold"
@export var icon: Texture2D
@export var is_premium: bool = false
@export var max_limit: int = 999999

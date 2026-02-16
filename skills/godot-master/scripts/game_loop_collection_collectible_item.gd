class_name CollectibleItem
extends Area3D

## A base class for items that can be collected (e.g., Hidden Eggs).
## Must be an Area3D or Area2D (Node type can be adapted).

# The ID this item belongs to (e.g., "red_egg_2024")
@export var collection_id: String = "easter_egg"

# If true, the item is removed from the scene upon collection.
@export var consume_on_collect: bool = true

# Optional: Sound or Particle effect to spawn on collection.
@export var vfx_on_collect: PackedScene

# Signal: Emitted when collected, providing the ID to the Manager.
signal item_collected(id: String)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	# Assume 'body' is the player.
	# In a real game, check: if body.is_in_group("player")
	collect()

func collect() -> void:
	# 1. Play feedback (Audio/VFX)
	if vfx_on_collect:
		var vfx = vfx_on_collect.instantiate()
		get_parent().add_child(vfx)
		vfx.global_position = global_position
	
	# 2. Notify Manager
	# The Manager should listen to this signal via manual connection of `get_tree().get_nodes_in_group("collectibles")`
	# OR simpler: Use a global signal bus.
	# Here, we emit locally. A manager would connect to this instance if spawned dynamically.
	item_collected.emit(collection_id)
	
	# 3. Destroy
	if consume_on_collect:
		queue_free()

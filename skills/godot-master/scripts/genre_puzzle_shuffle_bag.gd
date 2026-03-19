# shuffle_bag.gd
extends Node
class_name ShuffleBag

# Shuffle Bag for Procedural Generation
# Generates non-repeating random values (e.g., Match-3 block types).

var _items: Array[Variant] = []
var _full_items: Array[Variant] = []

func initialize(items_to_shuffle: Array) -> void:
    _full_items = items_to_shuffle.duplicate()
    _refill_and_shuffle()

func _refill_and_shuffle() -> void:
    _items = _full_items.duplicate()
    _items.shuffle()

func get_next() -> Variant:
    if _items.is_empty():
        # Pattern: Reinitialize when empty to guarantee fair distribution.
        _refill_and_shuffle()
    return _items.pop_front()

class_name RoguelikeRNG extends Resource

## Resource for managing seeded randomness and persistence.
## Stores the internal PCG32 state for deterministic reloads.

@export var seed_value: int = 0
var _rng := RandomNumberGenerator.new()

func initialize(new_seed: int) -> void:
	seed_value = new_seed
	_rng.seed = seed_value

func get_generator() -> RandomNumberGenerator:
	return _rng

## Replay-safe state capturing
func save_state() -> int:
	return _rng.state

func load_state(saved_state: int) -> void:
	_rng.seed = seed_value
	_rng.state = saved_state

## Utility for "fair" random using shuffle bag
func get_shuffled_bag(items: Array) -> Array:
	var bag := items.duplicate()
	bag.shuffle()
	return bag

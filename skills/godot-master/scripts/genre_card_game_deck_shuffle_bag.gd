# deck_shuffle_bag.gd
# Secure deck randomization using the "Shuffle Bag" pattern
extends Node

# EXPERT NOTE: Shuffle-bag logic prevents streaks of bad luck 
# by ensuring a uniform distribution over the deck lifetime.

var deck: Array[CardData] = []
var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func shuffle_deck():
	deck.shuffle() # Engine-level randomized shuffle

func draw_card() -> CardData:
	return deck.pop_back() if !deck.is_empty() else null

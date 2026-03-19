# route_manager.gd
# Manages character-specific narrative routes, persistence, and endings.
# Integrated with the AffectionManager for milestone-based route unlocking.

class_name RouteManager
extends Node

## Emitted when the player officially enters a character's route.
signal route_locked_in(character_id: String)

## Emitted when a new CG (Computer Graphic) or Gallery item is unlocked.
signal cg_unlocked(cg_id: String)

enum EndingType { BAD, NORMAL, GOOD, TRUE }

# State tracking
var current_route: String = ""
var is_route_active: bool = false
var unlocked_cgs: Array[String] = []

# Persistent data for gallery/completionist features
const SAVE_PATH = "user://romance_gallery.save"

func _ready() -> void:
	load_gallery()
	# Connect to affection milestones to potentially trigger route entries
	# AffectionManager.milestone_reached.connect(_on_affection_milestone)

## Attempts to lock in a character's route. 
## Returns true if successful, false if already on another route.
func lock_in_route(character_id: String) -> bool:
	if is_route_active:
		if current_route == character_id:
			return true
		else:
			push_warning("Attempted to enter %s route while already on %s route." % [character_id, current_route])
			return false
	
	current_route = character_id
	is_route_active = true
	unlock_cg(character_id + "_prologue")
	route_locked_in.emit(character_id)
	return true

## Unlocks a CG and saves to persistent storage.
func unlock_cg(cg_id: String) -> void:
	if not cg_id in unlocked_cgs:
		unlocked_cgs.append(cg_id)
		cg_unlocked.emit(cg_id)
		save_gallery()

## Pure logic for determining ending based on stats.
func determine_ending(character_id: String) -> EndingType:
	var stats: Dictionary = AffectionManager.get_stats(character_id)
	
	if stats["trust"] < 0:
		return EndingType.BAD
	
	if stats["attraction"] >= 80 and stats["trust"] >= 50:
		if stats["comfort"] >= 70:
			return EndingType.TRUE
		return EndingType.GOOD
	
	return EndingType.NORMAL

# --- Persistence ---

func save_gallery() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var data = {
			"unlocked_cgs": unlocked_cgs,
			"global_progress": {} # Can store multi-playthrough flags here
		}
		file.store_var(data)

func load_gallery() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var data = file.get_var()
			unlocked_cgs = data.get("unlocked_cgs", [])

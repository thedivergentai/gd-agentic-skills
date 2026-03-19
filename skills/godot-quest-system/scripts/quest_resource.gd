# quest_resource.gd
# Data-driven quest definition
class_name Quest extends Resource

# EXPERT NOTE: Defining quests as Resources allows for 
# branching logic and complex reward structures in the Inspector.

enum Status { AVAILABLE, ACTIVE, COMPLETED, FAILED }

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var objective_count: int = 1
@export var rewards: Array[InventoryItem] = []
@export var next_quest: Quest # For simple linear chains

var status: Status = Status.AVAILABLE
var current_count: int = 0

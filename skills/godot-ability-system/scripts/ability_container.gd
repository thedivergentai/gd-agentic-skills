# skills/ability-system/scripts/ability_container.gd
extends Node

## Ability Container Expert Pattern
## Composition-based ability manager for characters.

class_name AbilityContainer

signal ability_added(ability: Ability)
signal ability_removed(ability: Ability)
signal ability_activated(ability: Ability)
signal ability_cooldown_started(ability: Ability, time: float)

@export var initial_abilities: Array[PackedScene] # Scenes inheriting Ability class

var _abilities: Dictionary = {} # { "ability_name": AbilityNode }
var _cooldowns: Dictionary = {} # { "ability_name": Timer }

func _ready() -> void:
	for scene in initial_abilities:
		add_ability(scene)

func add_ability(ability_scene: PackedScene) -> void:
	var ability = ability_scene.instantiate() as Ability
	if not ability:
		push_error("Not an Ability scene")
		return
	
	add_child(ability)
	_abilities[ability.ability_name] = ability
	ability_added.emit(ability)
	
	# Create cooldown timer
	var timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	_cooldowns[ability.ability_name] = timer

func activate_ability(ability_name: String, context: Dictionary = {}) -> bool:
	var ability = _abilities.get(ability_name)
	if not ability:
		return false
	
	var timer = _cooldowns[ability_name]
	if not timer.is_stopped():
		return false # On cooldown
		
	if not ability.can_activate(context):
		return false
		
	ability.activate(context)
	ability_activated.emit(ability)
	
	if ability.cooldown > 0:
		timer.start(ability.cooldown)
		ability_cooldown_started.emit(ability, ability.cooldown)
		
	return true

## EXPERT USAGE:
## var container = $AbilityContainer
## container.activate_ability("Fireball", { "target": enemy_pos })

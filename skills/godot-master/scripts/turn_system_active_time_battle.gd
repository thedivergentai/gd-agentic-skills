# skills/turn-system/scripts/active_time_battle.gd
extends Node

## Active Time Battle (ATB) Expert Pattern
## Async-aware ATB system managing unit charge, actions, and wait states.

class_name ActiveTimeBattle

signal turn_ready(unit: Node)
signal turn_ended(unit: Node)

enum State { CHARGING, WAIT_FOR_INPUT, EXECUTING }

@export var max_charge: float = 100.0
@export var fill_rate_multiplier: float = 1.0

var units: Array[Node] = [] # Expects units to have 'speed' and 'charge' properties
var current_state: State = State.CHARGING
var active_unit: Node

func _process(delta: float) -> void:
	if current_state == State.CHARGING:
		_process_charging(delta)

func _process_charging(delta: float) -> void:
	for unit in units:
		if is_instance_valid(unit):
			# Logic: Speed * Multiplier * Delta
			var speed = unit.get("speed") if "speed" in unit else 10.0
			var current = unit.get("charge") if "charge" in unit else 0.0
			
			current += speed * fill_rate_multiplier * delta
			unit.set("charge", current)
			
			if current >= max_charge:
				_start_turn(unit)
				return # Process one turn start per frame to avoid conflicts

func _start_turn(unit: Node) -> void:
	current_state = State.WAIT_FOR_INPUT
	active_unit = unit
	turn_ready.emit(unit)
	
	# Pause charging for others if "Wait" mode is desired
	# set_process(false) 

func submit_action(action_lambda: Callable) -> void:
	if current_state != State.WAIT_FOR_INPUT:
		return
		
	current_state = State.EXECUTING
	
	# Execute async action
	await action_lambda.call()
	
	_end_turn()

func _end_turn() -> void:
	if is_instance_valid(active_unit):
		active_unit.set("charge", 0.0)
		turn_ended.emit(active_unit)
	
	active_unit = null
	current_state = State.CHARGING
	# set_process(true)

## EXPERT USAGE:
## atb.turn_ready.connect(func(u): show_menu(u))
## atb.submit_action(func(): await u.attack(target))

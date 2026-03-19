# skills/genre-rts/scripts/rts_unit.gd
extends CharacterBody2D

## RTS Unit Entity (Expert Pattern)
## Handles state machine logic (Idle, Move, Attack) and pathfinding.
## Integrates with NavigationAgent2D for RVO avoidance.

class_name RTSUnit

enum State { IDLE, MOVE, ATTACK, HOLD }

@export var speed: float = 150.0
@export var attack_range: float = 40.0
@export var damage: int = 5
@export var nav_agent: NavigationAgent2D

var state: State = State.IDLE
var current_target: Node2D
var _is_selected: bool = false
@onready var selection_visual: Sprite2D = $SelectionCircle

func _ready() -> void:
    # Setup RVO
    nav_agent.velocity_computed.connect(_on_velocity_computed)
    nav_agent.avoidance_enabled = true
    nav_agent.radius = 20.0
    
    if selection_visual:
        selection_visual.visible = false

func move_to(target_pos: Vector2) -> void:
    nav_agent.target_position = target_pos
    state = State.MOVE

func set_selected(selected: bool) -> void:
    _is_selected = selected
    if selection_visual:
        selection_visual.visible = selected

func _physics_process(delta: float) -> void:
    if state == State.MOVE:
        if nav_agent.is_navigation_finished():
            state = State.IDLE
            velocity = Vector2.ZERO
            return
            
        var next = nav_agent.get_next_path_position()
        var dir = global_position.direction_to(next)
        
        # Trigger avoidance calc
        nav_agent.set_velocity(dir * speed)
        
    elif state == State.ATTACK:
        # Attack logic here
        pass

func _on_velocity_computed(safe_velocity: Vector2) -> void:
    # Callback from RVO avoidance
    velocity = safe_velocity
    move_and_slide()

## EXPERT USAGE:
## Attach NavigationAgent2D CHILD. Assign it to 'nav_agent'.
## Connect 'velocity_computed' signal in inspector or _ready (done above).

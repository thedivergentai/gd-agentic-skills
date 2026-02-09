# skills/genre-sports/scripts/team_manager.gd
extends Node

## Team AI Manager (Expert Pattern)
## Manages formations and assigns roles (Attacker, Defender) dynamically.
## Prevents "Kindergarten Soccer" (everyone chasing the ball).

class_name TeamManager

enum Strategy { ATTACK, DEFEND }

@export var formation_anchor: Node3D
@export var players: Array[Node3D] # AI Controllers
@export var ball: RigidBody3D

var current_strategy: Strategy = Strategy.DEFEND
var formation_slots: Array[Node3D] = []

func _ready() -> void:
    # Collect formation slots (markers)
    for child in formation_anchor.get_children():
        if child is Marker3D:
            formation_slots.append(child)

func _physics_process(delta: float) -> void:
    if not ball: return
    
    # 1. Determine Strategy
    if _team_has_possession():
        current_strategy = Strategy.ATTACK
    else:
        current_strategy = Strategy.DEFEND
        
    # 2. Move Anchor
    # Anchor generally follows ball but stays on team's side or moves upfield
    var target_pos = ball.global_position
    if current_strategy == Strategy.DEFEND:
         target_pos.z *= 0.5 # Stay closer to goal
    
    formation_anchor.global_position = formation_anchor.global_position.lerp(target_pos, delta)
    
    # 3. Assign Roles
    var best_player = _find_closest_player_to_ball()
    
    for i in range(players.size()):
        var player = players[i]
        if player == best_player:
             # Press the ball
             player.set_target(ball.global_position)
             player.set_state("CHASE")
        else:
             # Go to formation slot
             if i < formation_slots.size():
                 player.set_target(formation_slots[i].global_position)
                 player.set_state("FORMATION")

func _team_has_possession() -> bool:
    # Logic to check if any team member is controlling the ball
    return false 

func _find_closest_player_to_ball() -> Node3D:
    var best: Node3D = null
    var min_dist = INF
    for p in players:
        var d = p.global_position.distance_to(ball.global_position)
        if d < min_dist:
            min_dist = d
            best = p
    return best

## EXPERT USAGE:
## Setup Player AI with set_target/set_state methods.
## Create Formation Node with Marker3D children.

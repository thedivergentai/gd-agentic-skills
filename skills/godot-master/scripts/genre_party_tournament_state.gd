# tournament_state.gd
extends Node
# Configured as an Autoload named 'TournamentState'

# Global Tournament State (Autoload)
# Persists scores and round progression across minigame scene switches.

var player_scores: Dictionary = {} # player_id -> score
var current_round: int = 1
var active_players: Dictionary = {} # device_id mapping

func award_points(player_id: int, points: int) -> void:
    player_scores[player_id] = player_scores.get(player_id, 0) + points

func reset_tournament() -> void:
    player_scores.clear()
    current_round = 1

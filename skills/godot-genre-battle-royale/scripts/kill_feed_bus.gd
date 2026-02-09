# skills/genre-battle-royale/code/kill_feed_bus.gd
extends Node

## Kill-Feed Signal Bus Expert Pattern
## Global hub for tracking eliminations and weapon stats.

# player_id, killer_id, weapon_type
signal elimination_occurred(victim: String, killer: String, weapon: String)

var _match_stats = {}

func log_elimination(victim: String, killer: String, weapon: String) -> void:
    # 1. Broadly Emit
    # Every UI component and logging system listens to this single point.
    elimination_occurred.emit(victim, killer, weapon)
    
    # 2. Persist Match State
    # Record for post-game summary.
    if not _match_stats.has(killer):
        _match_stats[killer] = 0
    _match_stats[killer] += 1

func get_killer_rankings() -> Array:
    # 3. Data Transformation
    # Returns a sorted array of killer names for the match summary.
    var rankings = _match_stats.keys()
    rankings.sort_custom(func(a, b): return _match_stats[a] > _match_stats[b])
    return rankings

## EXPERT NOTE:
## For true Battle Royale scale (100+ players), use 'Area Interest' 
## networking to only send kill-feed data to players whom it concerns, 
## unless it's a 'Major Event' like the top 10 players remaining.

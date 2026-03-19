class_name AudioVoiceLimiterManager
extends Node

## Expert SFX instance limiter.
## Prevents 'Phasing' and 'Ear Bleed' by capping identical sound instances.

var active_counts: Dictionary = {}

func can_play(sound_id: String, limit: int = 5) -> bool:
	var count = active_counts.get(sound_id, 0)
	if count >= limit:
		return false
	
	active_counts[sound_id] = count + 1
	# Logic to decrement count when sound finishes...
	return true

## Rule: Limit weapons/explosions to 5-10 concurrent instances to maintain clarity.

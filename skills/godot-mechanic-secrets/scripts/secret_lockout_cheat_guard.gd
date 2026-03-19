class_name SecretLockoutCheatGuard
extends Node

## Expert Anti-Brute Force Guard.
## Prevents automated scripts from guessing cheat codes.

@export var max_failed_attempts: int = 3
@export var lockout_duration: float = 30.0

var failed_attempts: int = 0
var is_locked: bool = false

func register_failure() -> void:
	failed_attempts += 1
	if failed_attempts >= max_failed_attempts:
		_start_lockout()

func _start_lockout() -> void:
	is_locked = true
	await get_tree().create_timer(lockout_duration).timeout
	is_locked = false
	failed_attempts = 0

## Rule: Always provide a subtle 'Denied' sound cue when a player is in lockout mode.

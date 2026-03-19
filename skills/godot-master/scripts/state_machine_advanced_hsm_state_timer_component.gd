class_name HSMStateTimerComponent
extends Timer

## Expert component for State machine auto-transitions.
## Automatically triggers a state exit/transition after a set duration.

signal state_timeout

func start_state_timer(duration: float) -> void:
	wait_time = duration
	one_shot = true
	start()
	timeout.connect(func(): state_timeout.emit(), CONNECT_ONE_SHOT)

## Rule: Use timers for finite states like 'Stun', 'WallClip', or 'Dash'.

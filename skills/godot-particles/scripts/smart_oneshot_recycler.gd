# smart_oneshot_recycler.gd
# Robust lifecycle management for one-shot VFX
extends GPUParticles3D

func _ready() -> void:
	one_shot = true
	# Relying on the 'finished' signal is the ONLY safe way to free VFX [40].
	finished.connect(_on_vfx_finished)
	emitting = true

func _on_vfx_finished() -> void:
	# Handle recycling or freeing
	queue_free()

func trigger_restart() -> void:
	# Anti-pattern fix: setting emitting=true directly after finished 
	# can fail due to GPU async state. Use restart() instead [41].
	restart()

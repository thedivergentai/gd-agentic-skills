# array_preallocation_perf.gd
# Avoiding reallocation spikes by pre-sizing large arrays
extends Node

# EXPERT NOTE: Calling append() 10,000 times triggers hundreds of 
# expensive memory reallocations. Always resize() first.

func fast_generate_lattice(size: int) -> PackedVector3Array:
	var lattice := PackedVector3Array()
	# Pre-allocate memory instantly
	lattice.resize(size * size)
	
	for i in size:
		for j in size:
			# Index-based assignment is significantly faster than append()
			lattice[i * size + j] = Vector3(i, 0, j)
			
	return lattice

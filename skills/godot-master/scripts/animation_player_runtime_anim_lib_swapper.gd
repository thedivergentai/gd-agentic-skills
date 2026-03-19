# runtime_anim_lib_swapper.gd
# Swapping AnimationLibraries at runtime for massive character variety
extends AnimationPlayer

# AnimationLibraries allow grouping animations. Swapping them 
# allows different "Stances" or "Weapon Sets" to share the same 
# AnimationPlayer node.

func load_stance_library(lib_path: String, stance_name: String) -> void:
	var new_lib: AnimationLibrary = load(lib_path)
	
	# Remove old if it exists
	if has_animation_library(stance_name):
		remove_animation_library(stance_name)
	
	# Add the new set (e.g., "sword_stance", "bow_stance")
	add_animation_library(stance_name, new_lib)
	
	# Play from the specific library
	# Format: "lib_name/anim_name"
	play(stance_name + "/idle")

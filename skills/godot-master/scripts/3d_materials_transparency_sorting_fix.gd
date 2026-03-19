# Transparency Sorting Fix Logic
extends MeshInstance3D

## Resolves artifacts where back surfaces appear in front of closer ones.
## Covers Alpha Scissor vs Alpha Hash vs Depth Draw strategies.

func use_cutout_transparency() -> void:
	var mat = material_override as StandardMaterial3D
	# Best performance, writes to depth buffer, casts shadows
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat.alpha_scissor_threshold = 0.5

func use_dithered_transparency() -> void:
	var mat = material_override as StandardMaterial3D
	# Perceptually smooth fade, no sorting artifacts, slower than scissor
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH

func enforce_depth_prepass() -> void:
	var mat = material_override as StandardMaterial3D
	# Resolves overlapping alpha-blended sorting issues
	mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS

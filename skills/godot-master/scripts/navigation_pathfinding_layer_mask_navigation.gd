# layer_mask_navigation.gd
# Toggling agent capabilities (e.g. Flying vs Walking) using bitmasks
extends Node

enum NavLayers {
	WALK = 1,
	JUMP = 2,
	FLY = 4,
	SWIM = 8
}

func set_agent_capability(agent_rid: RID, layers: int) -> void:
	# Navigation layers use a 32-bit integer bitmask.
	# This allows one agent to only use specific regions/links.
	NavigationServer3D.agent_set_navigation_layers(agent_rid, layers)

func unlock_swimming(agent_rid: RID) -> void:
	var mask = NavigationServer3D.agent_get_navigation_layers(agent_rid)
	mask |= NavLayers.SWIM # Add swim bit
	NavigationServer3D.agent_set_navigation_layers(agent_rid, mask)

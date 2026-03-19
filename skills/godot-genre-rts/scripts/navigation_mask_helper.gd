# navigation_mask_helper.gd
extends RefCounted
class_name NavigationMaskHelper

# Navigation Layer Bitmasking for Avoidance
# Dynamically alters agent layers to ignore hazard regions or locked gates.

static func toggle_navigation_layer(agent: NavigationAgent3D, layer_index: int, enabled: bool) -> void:
    # Pattern: Bitwise masking for efficient layer management.
    if enabled:
        agent.navigation_layers |= (1 << layer_index)
    else:
        agent.navigation_layers &= ~(1 << layer_index)

static func set_swimming_capability(agent: NavigationAgent3D, can_swim: bool) -> void:
    # Example: Layer 2 is water.
    toggle_navigation_layer(agent, 2, can_swim)

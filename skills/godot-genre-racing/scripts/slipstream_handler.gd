# slipstream_handler.gd
extends Area3D
class_name SlipstreamHandler

# Slipstream/Drafting Mechanics
# Provides a velocity boost when following a lead car within a specific cone.

@export var boost_multiplier := 1.2
@export var max_angle_deg := 15.0

func _on_area_entered(area: Area3D) -> void:
    var parent = get_parent()
    if area.get_parent() is ArcadeVehicleController:
        var lead_car = area.get_parent()
        var to_lead = (lead_car.global_position - parent.global_position).normalized()
        var dot = to_lead.dot(-lead_car.global_transform.basis.z)
        
        # Pattern: Verify dot product to ensure we are actually behind the car.
        if dot > cos(deg_to_rad(max_angle_deg)):
            _apply_draft_boost(parent)

func _apply_draft_boost(car: Node3D) -> void:
    if "velocity" in car:
        car.velocity *= boost_multiplier

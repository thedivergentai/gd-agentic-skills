# weapon_spread_calc.gd
extends RefCounted
class_name WeaponSpreadCalc

# Normal Distribution Bullet Spread
# Bullets cluster near the crosshair using Gaussian distribution.

static func calculate_spread(forward: Vector3, spread_degrees: float) -> Vector3:
    # Pattern: randfn() clusters around 0.0 for more realistic clustering.
    var dev_x := deg_to_rad(randfn(0.0, spread_degrees))
    var dev_y := deg_to_rad(randfn(0.0, spread_degrees))
    
    var spread_basis := Basis()
    spread_basis = spread_basis.rotated(Vector3.UP, dev_x)
    spread_basis = spread_basis.rotated(Vector3.RIGHT, dev_y)
    
    return spread_basis * forward

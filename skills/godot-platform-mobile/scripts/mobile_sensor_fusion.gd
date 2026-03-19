class_name MobileSensorFusion
extends Node

## Expert usage of mobile hardware sensors for motion controls.
## Fuses Accelerometer and Gravity for stable gameplay input.

func get_tilt_input() -> Vector3:
	var accel := Input.get_accelerometer()
	var gravity := Input.get_gravity()
	
	# Compute stable tilt by subtracting gravity from raw accelerometer
	var tilt := accel - gravity
	return tilt.normalized()

func get_device_rotation() -> Vector3:
	return Input.get_gyroscope()

## Rule: Always normalize sensor data to account for varying hardware sensitivity.

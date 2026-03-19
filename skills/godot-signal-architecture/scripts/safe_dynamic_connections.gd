# safe_dynamic_connections.gd
# Verifying connection state to prevent runtime errors
extends Node

func connect_sensor(sensor: Node):
	var callback = _on_sensor_triggered
	
	# Connecting a connected signal is a runtime error.
	if not sensor.triggered.is_connected(callback):
		sensor.triggered.connect(callback)

func _on_sensor_triggered():
	print("Sensor activity detected.")

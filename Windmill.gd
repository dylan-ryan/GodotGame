extends Node3D

@export var rotation_speed: float = 60.0  # Degrees per second

func _process(delta: float) -> void:
	rotate_z(deg_to_rad(rotation_speed * delta))

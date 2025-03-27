extends RigidBody3D

@onready var spawn1 = $"/root/main/World/Spawn"
@onready var ball_spawn1 = $"/root/main/World/BallSpawn"
@onready var spawn2 = $"/root/main/World2/Spawn2"
@onready var ball_spawn2 = $"/root/main/World2/BallSpawn2"
@onready var spawn3 = $"/root/main/World3/Spawn3"
@onready var ball_spawn3 = $"/root/main/World3/BallSpawn3"

func _ready() -> void:
	add_to_group("pickupable")

func _physics_process(delta: float) -> void:
	if global_position.y < -3:
		var current_world = "World"
		if global_position.x > 0 and global_position.x < 50:
			current_world = "World2"
		elif global_position.x >= 50:
			current_world = "World3"
		
		match current_world:
			"World":
				global_position = ball_spawn1.global_position
			"World2":
				global_position = ball_spawn2.global_position
			"World3":
				global_position = ball_spawn3.global_position
		
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO

func _on_area_3d_body_entered(body: Node3D) -> void:
	pass # Replace with function body.

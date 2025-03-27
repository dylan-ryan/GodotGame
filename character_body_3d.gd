extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 8.0
@export var gravity: float = 20.0
@export var mouse_sensitivity: float = 0.1
@export var pickup_distance: float = 2.0
@export var hold_smoothness: float = 10.0

const GROUND_LAYER = 1

var pitch: float = 0.0
var shots: int = 0
@onready var head: Node3D = $Head
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var shots_text: Label = $"/root/main/Canvas/ShotsText"
@onready var spawn = $"/root/main/World/Spawn"
@onready var spawn2 = $"/root/main/World2/Spawn2"
@onready var spawn3 = $"/root/main/World3/Spawn3"
var holding_ball: bool = false
var picked_up_ball: RigidBody3D = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	raycast.enabled = true
	shots_text.text = "SHOTS: 0"

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity * 0.01)
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity * 0.01, deg_to_rad(-80), deg_to_rad(80))
		head.rotation.x = pitch
	
	if Input.is_action_pressed("click"):
		try_pick_up_ball()
	
	if !Input.is_action_pressed("click"):
		drop_ball()

func _physics_process(delta: float) -> void:
	if not holding_ball:
		var direction = Vector3.ZERO
		var forward = -transform.basis.z
		var right = transform.basis.x

		if Input.is_action_pressed("move_forward"):
			direction += forward
		if Input.is_action_pressed("move_backward"):
			direction -= forward
		if Input.is_action_pressed("move_left"):
			direction -= right
		if Input.is_action_pressed("move_right"):
			direction += right

		direction = direction.normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
		else:
			velocity.y = 0

	move_and_slide()
	
	if holding_ball and picked_up_ball != null:
		var camera = $Head/Camera3D
		var target_position = camera.global_position + camera.global_transform.basis.z * -pickup_distance
		target_position.y -= 0.5
		
		var ground_ray = RayCast3D.new()
		ground_ray.target_position = Vector3(0, -10, 0)
		ground_ray.collision_mask = GROUND_LAYER
		ground_ray.exclude_parent = true
		ground_ray.add_exception(picked_up_ball)
		add_child(ground_ray)
		
		ground_ray.global_position = target_position
		ground_ray.force_raycast_update()
		var target_ground_y = target_position.y
		if ground_ray.is_colliding():
			target_ground_y = ground_ray.get_collision_point().y + 0.5
		
		ground_ray.global_position = picked_up_ball.global_position
		ground_ray.force_raycast_update()
		var current_ground_y = picked_up_ball.global_position.y
		if ground_ray.is_colliding():
			current_ground_y = ground_ray.get_collision_point().y + 0.5
		
		ground_ray.queue_free()
		
		target_position.y = max(target_position.y, target_ground_y, current_ground_y)
		
		picked_up_ball.global_position = picked_up_ball.global_position.lerp(target_position, hold_smoothness * delta)
	
	if global_position.y < -3:
		var current_world = "World"
		if global_position.x > 0 and global_position.x < 50:
			current_world = "World2"
		elif global_position.x >= 50:
			current_world = "World3"
		
		match current_world:
			"World":
				reset_to_spawn(spawn.global_position)
			"World2":
				reset_to_spawn(spawn2.global_position)
			"World3":
				reset_to_spawn(spawn3.global_position)

func reset_to_spawn(spawn_pos: Vector3):
	global_position = spawn_pos
	velocity = Vector3.ZERO

func try_pick_up_ball():
	if raycast.is_colliding():
		var colliding_object = raycast.get_collider()
		if colliding_object and colliding_object.is_in_group("pickupable"):
			if not holding_ball:
				pick_up_ball(colliding_object)

func pick_up_ball(ball: RigidBody3D):
	holding_ball = true
	picked_up_ball = ball
	picked_up_ball.freeze = true
	var camera = $Head/Camera3D
	var hold_position = camera.global_position + camera.global_transform.basis.z * -pickup_distance
	hold_position.y -= 0.5
	
	var ground_ray = RayCast3D.new()
	ground_ray.target_position = Vector3(0, -10, 0)
	ground_ray.collision_mask = GROUND_LAYER
	ground_ray.exclude_parent = true
	ground_ray.add_exception(picked_up_ball)
	add_child(ground_ray)
	
	ground_ray.global_position = hold_position
	ground_ray.force_raycast_update()
	var target_ground_y = hold_position.y
	if ground_ray.is_colliding():
		target_ground_y = ground_ray.get_collision_point().y + 0.5
	
	ground_ray.global_position = picked_up_ball.global_position
	ground_ray.force_raycast_update()
	var current_ground_y = picked_up_ball.global_position.y
	if ground_ray.is_colliding():
		current_ground_y = ground_ray.get_collision_point().y + 0.5
	
	ground_ray.queue_free()
	
	hold_position.y = max(hold_position.y, target_ground_y, current_ground_y)
	
	picked_up_ball.global_position = hold_position

func drop_ball():
	if holding_ball:
		holding_ball = false
		picked_up_ball.freeze = false
		var throw_force = -transform.basis.z * 10.0
		picked_up_ball.linear_velocity = throw_force
		shots += 1
		shots_text.text = "SHOTS: " + str(shots)
		picked_up_ball = null

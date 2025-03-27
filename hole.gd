extends CSGCylinder3D

@onready var score_text: Label = $"/root/main/Canvas/ScoreText"
@onready var player = $"/root/main/Player"
@onready var ball: RigidBody3D = $"/root/main/Ball/RigidBody3D"
@onready var spawn2 = $"/root/main/World2/Spawn2"
@onready var ball_spawn2 = $"/root/main/World2/BallSpawn2"
@onready var spawn3 = $"/root/main/World3/Spawn3"
@onready var ball_spawn3 = $"/root/main/World3/BallSpawn3"
@onready var win_bg = $"/root/main/Canvas/WinBG"
@onready var win_text = $"/root/main/Canvas/WinText"

static var current_hole: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var current_world = get_parent().get_parent().name
	if current_world == "World":
		current_hole = 1
		score_text.text = "HOLE: 1"
	
	win_bg.hide()
	win_text.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reset_ball_position(new_pos: Vector3):
	ball.freeze = true
	ball.global_position = new_pos
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	await get_tree().create_timer(0.1).timeout
	ball.freeze = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("pickupable"):
		current_hole += 1
		score_text.text = "HOLE: " + str(current_hole)
		
		if current_hole > 3:
			win_bg.show()
			win_text.show()
			return
		
		var current_world = get_parent().get_parent().name
		match current_world:
			"World":
				player.global_position = spawn2.global_position
				reset_ball_position(ball_spawn2.global_position)
			"World2":
				player.global_position = spawn3.global_position
				reset_ball_position(ball_spawn3.global_position)
			"World3":
				win_bg.show()
				win_text.show()

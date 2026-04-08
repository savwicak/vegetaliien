extends CharacterBody2D

# ===== SHOOTING =====
@export var bullet_scene: PackedScene
@onready var shoot_point = $ShootPoint

# ===== MOVEMENT =====
@export var max_speed := 200
@export var acceleration := 800
@export var friction := 600

# ===== CAMERA SHAKE =====
@export var shake_fade := 5.0
var shake_strength := 0.0
var rng = RandomNumberGenerator.new()

@onready var camera = $Camera2D

func _ready():
	rng.randomize()

func _physics_process(delta):
	# ===== INPUT =====
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_dir = input_dir.normalized()

	# ===== SHOOT =====
	if Input.is_action_just_pressed("shoot"):
		shoot()

	# ===== MOVEMENT =====
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
		
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()

	# ===== CAMERA SHAKE =====
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
		
		camera.offset = Vector2(
			rng.randf_range(-shake_strength, shake_strength),
			rng.randf_range(-shake_strength, shake_strength)
		)
	else:
		camera.offset = Vector2.ZERO

# ===== SHOOT FUNCTION =====
func shoot():
	if bullet_scene == null:
		print("BELUM MASUKIN BULLET SCENE")
		return

	var bullet = bullet_scene.instantiate()
	bullet.global_position = shoot_point.global_position

	# arah ke mouse 🔥
	var direction = (get_global_mouse_position() - shoot_point.global_position).normalized()
	bullet.direction = direction
	bullet.rotation = direction.angle()

	get_tree().current_scene.add_child(bullet)

	# optional: shake dikit biar keren
	shake(5)


# ===== CAMERA SHAKE FUNCTION =====
func shake(power: float):
	shake_strength = power

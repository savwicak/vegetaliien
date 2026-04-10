extends CharacterBody2D

# ===== NODE REFERENCES =====
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shoot_point: Node2D = $ShootPoint
@onready var camera: Camera2D = $Camera2D

# ===== SHOOTING =====
@export var bullet_scene: PackedScene

# ===== MOVEMENT =====
@export var max_speed: float = 200.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0

# ===== STAMINA SYSTEM =====
@export var max_stamina := 100.0
@export var stamina_gain := 20.0
var current_stamina := 0.0

# UI stamina (drag ProgressBar ke sini di Inspector)
@onready var stamina_bar: TextureProgressBar = get_node("/root/Main/CanvasLayer/Control/ProgressBar")

# ===== DAMAGE & KNOCKBACK =====
@export var knockback_power: float = 400.0
@export var knockback_friction: float = 800.0
@export var flash_duration: float = 0.1

var knockback_velocity: Vector2 = Vector2.ZERO
var is_invincible: bool = false

# ===== CAMERA SHAKE =====
@export var shake_fade: float = 5.0
var shake_strength: float = 0.0
var rng := RandomNumberGenerator.new()

# ==========================================================
# READY
# ==========================================================
func _ready():
	rng.randomize()
	add_to_group("player")

	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina

	update_stamina_ui()

# ==========================================================
# PHYSICS PROCESS
# ==========================================================
func _physics_process(delta):
	handle_movement(delta)
	handle_animation()
	handle_shooting()
	handle_camera_shake(delta)

	move_and_slide()

# ==========================================================
# MOVEMENT & KNOCKBACK
# ==========================================================
func handle_movement(delta):
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(
			Vector2.ZERO, knockback_friction * delta
		)
		return

	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_dir = input_dir.normalized()

	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

# ==========================================================
# ANIMATION
# ==========================================================
func handle_animation():
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

	if velocity.length() > 10:
		sprite.play("walk")
	else:
		sprite.play("idle")

# ==========================================================
# SHOOTING WITH STAMINA
# ==========================================================
func handle_shooting():
	if Input.is_action_just_pressed("shoot"):
		if current_stamina >= max_stamina:
			shoot()
			current_stamina = 0
			update_stamina_ui()
		else:
			print("Stamina belum penuh!")

func shoot():
	if bullet_scene == null:
		print("BELUM MASUKIN BULLET SCENE")
		return

	var bullet = bullet_scene.instantiate()
	bullet.global_position = shoot_point.global_position

	var direction = (get_global_mouse_position() - shoot_point.global_position).normalized()
	bullet.direction = direction
	bullet.rotation = direction.angle()

	get_tree().current_scene.add_child(bullet)
	shake(5)

# ==========================================================
# STAMINA
# ==========================================================
func add_stamina(amount: float):
	current_stamina = clamp(current_stamina + amount, 0, max_stamina)

	# efek kecil
	scale = Vector2(1.1, 1.1)
	await get_tree().create_timer(0.05).timeout
	scale = Vector2(1,1)

	update_stamina_ui()

func update_stamina_ui():
	if stamina_bar:
		var tween = create_tween()
		tween.tween_property(stamina_bar, "value", current_stamina, 0.2)
	else:
		push_warning("StaminaBar tidak ditemukan!")
# ==========================================================
# DAMAGE, KNOCKBACK & FLASH
# ==========================================================
func take_damage(from_position: Vector2):
	if is_invincible:
		return

	is_invincible = true

	var direction = (global_position - from_position).normalized()
	knockback_velocity = direction * knockback_power

	flash_red()
	shake(8)

	# Mengurangi HP melalui UI
	get_node("/root/Main/CanvasLayer/HBoxContainer").take_damage(1)

	await get_tree().create_timer(0.5).timeout
	is_invincible = false

func flash_red():
	sprite.modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(flash_duration).timeout
	sprite.modulate = Color(1, 1, 1)

# ==========================================================
# CAMERA SHAKE
# ==========================================================
func shake(power: float):
	shake_strength = power

func handle_camera_shake(delta):
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
		camera.offset = Vector2(
			rng.randf_range(-shake_strength, shake_strength),
			rng.randf_range(-shake_strength, shake_strength)
		)
	else:
		camera.offset = Vector2.ZERO
		

@export var timeline_name: String = "tutorial"

@onready var player = $"../Player"

var waiting_for_move = false

# ==================================================
# START TUTORIAL
# ==================================================
func run_tutorial():
	Dialogic.start(timeline_name)

	if not Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.connect(_on_dialogic_signal)

# ==================================================
# SIGNAL DARI DIALOGIC
# ==================================================
func _on_dialogic_signal(argument: String):
	print("SIGNAL:", argument)

	if argument == "tunggu_gerak":
		waiting_for_move = true
		
		# kasih kontrol ke player
		player.set_physics_process(true)

		# pause dialog
		Dialogic.pause()

# ==================================================
# CEK PLAYER GERAK
# ==================================================
func _process(delta):
	if waiting_for_move:
		if player.velocity.length() > 0:
			print("PLAYER UDAH GERAK!")

			waiting_for_move = false

			# matiin player lagi (biar lanjut dialog)
			player.set_physics_process(false)

			# lanjut dialog 🔥
			Dialogic.resume()

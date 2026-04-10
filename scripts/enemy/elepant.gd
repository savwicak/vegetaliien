extends CharacterBody2D

# --- CONFIGURATION ---
@export var speed: float = 100
@export var health: int = 6
@export var knockback_power: float = 150.0
@export var knockback_friction: float = 80.0

# --- STATE ---
var player_near: bool = false
var is_active: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO

# --- NODE REFERENCES ---
@onready var player: Node2D = get_tree().get_first_node_in_group("player")
@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_area: Area2D = $Area2D
@onready var damage_area: Area2D = get_node_or_null("DamageArea")
@onready var hitbox: Area2D = get_node_or_null("Hitbox")
@onready var label: Label = $Label

func _ready():
	add_to_group("enemies")

	# Validasi player
	if player == null:
		push_warning("Player tidak ditemukan di group 'player'.")

	# Interaction signals
	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)
	label.visible = false

	# Damage area signal
	if damage_area:
		damage_area.body_entered.connect(_on_damage_area_body_entered)
	else:
		push_error("DamageArea tidak ditemukan!")

	# Hitbox signal (untuk menerima damage dari peluru)
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

	# Dialogic signal
	if Dialogic and not Dialogic.signal_event.is_connected(_on_dialog_signal):
		Dialogic.signal_event.connect(_on_dialog_signal)

# --- DIALOG ACTIVATION ---
func _on_dialog_signal(arg: String):
	if arg == "start_enemy":
		is_active = true
		label.visible = false

		# Hapus area interaksi agar tidak bisa dialog lagi
		if interact_area:
			interact_area.queue_free()

# --- INTERACTION ---
func _process(delta):
	if player_near and not is_active and Input.is_action_just_pressed("interact"):
		start_dialog()

func start_dialog():
	Dialogic.start("elepant")

func _on_body_entered(body):
	if body.is_in_group("player") and not is_active:
		player_near = true
		label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
		label.visible = false

# --- MOVEMENT & CHASING ---
func _physics_process(delta):
	if not is_active or player == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = (player.global_position - global_position).normalized()

	# Handle knockback
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
	else:
		velocity = direction * speed

	# Flip sprite
	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0

	move_and_slide()

	# Reduce knockback over time
	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO, knockback_friction * delta
	)

# --- DAMAGE TO PLAYER ---
func _on_damage_area_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(global_position)

# --- DAMAGE FROM BULLETS ---
func _on_hitbox_body_entered(body):
	if body.is_in_group("bullet"):
		take_damage()
		flash_red()
		apply_knockback(body.global_position, knockback_power)
		body.queue_free()

func take_damage():
	health -= 1
	print("Elepant HP:", health)

	if health <= 0:
		die()

func die():
	queue_free()

# --- KNOCKBACK EFFECT ---
func apply_knockback(from_position: Vector2, power: float):
	var dir = (global_position - from_position).normalized()
	knockback_velocity = dir * power

# --- VISUAL FEEDBACK ---
func flash_red():
	sprite.modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)

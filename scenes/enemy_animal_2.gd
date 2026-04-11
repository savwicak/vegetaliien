extends CharacterBody2D

@export var speed := 70
@onready var sprite: Sprite2D = $Sprite2D
@onready var target = $"../Player"

var is_stunned = false

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO
@export var knockback_friction := 80

# Referensi ke DamageArea (aman dari error null)
@onready var damage_area: Area2D = get_node_or_null("DamageArea")

func _ready():
	add_to_group("enemies")
	
	if damage_area:
		damage_area.body_entered.connect(_on_damage_area_body_entered)
	else:
		push_error("DamageArea tidak ditemukan! Pastikan node bernama 'DamageArea' ada di dalam scene Enemy.")

func _physics_process(delta):
	if target == null:
		return

	# Flip sprite
	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0

	var direction = (target.global_position - global_position).normalized()

	# Knockback tetap jalan
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
	else:
		velocity = direction * speed

	move_and_slide()

	# Reduksi knockback
	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO, knockback_friction * delta
	)

# Fungsi saat player memasuki area damage
func _on_damage_area_body_entered(body):
	print("Masuk ke DamageArea:", body.name)
	if body.is_in_group("player"):
		print("Player terkena damage!")
		body.take_damage(global_position)

# Efek knockback ketika terkena peluru
func apply_knockback(from_position: Vector2, power: float):
	var dir = (global_position - from_position).normalized()
	knockback_velocity = dir * power * 2
	flash_red()
	

# Efek flash merah saat terkena damage
func flash_red():
	sprite.modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)

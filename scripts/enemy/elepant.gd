extends CharacterBody2D

var player_near = false
var is_active = false
var speed = 100
var health = 6

@onready var player = null

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)
	$Label.visible = false
	
	# ambil player lebih aman
	player = get_tree().get_first_node_in_group("player")
	
	# connect dialogic
	Dialogic.signal_event.connect(_on_dialog_signal)
	
func _on_dialog_signal(arg):
	if arg == "start_enemy":
		is_active = true
		$Label.visible = false
		
		$Area2D.queue_free() # 💀 HAPUS AREA

func _process(delta):
	if player_near and Input.is_action_just_pressed("interact"):
		start_dialog()

func _physics_process(delta):
	if not is_active:
		return
	
	if player == null:
		print("PLAYER NULL ❌")
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

func _on_body_entered(body):
	if body.name == "Player" and not is_active:
		player_near = true
		$Label.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		player_near = false
		$Label.visible = false

func start_dialog():
	Dialogic.start("elepant")

func take_damage():
	health -= 1
	print("HP:", health)

	if health <= 0:
		die()

func die():
	queue_free()

func _on_hitbox_body_entered(body):
	if body.is_in_group("bullet"):
		take_damage()
		body.queue_free()

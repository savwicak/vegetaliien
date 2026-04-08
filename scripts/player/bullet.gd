extends Area2D

@export var speed := 600
var direction := Vector2.ZERO

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		print("KENA ENEMY")
		body.queue_free() # musuh hilang
		queue_free() # peluru hilang

	if body.is_in_group("wall"):
		queue_free()

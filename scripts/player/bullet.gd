extends Area2D

@export var speed := 600
@export var damage := 1
@export var knockback_power := 60.0

var direction := Vector2.ZERO

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(global_position, knockback_power)
		queue_free()

	if body.is_in_group("border"):
		queue_free()

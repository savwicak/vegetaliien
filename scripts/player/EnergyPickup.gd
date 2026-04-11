extends Area2D

signal picked_up

@export var stamina_amount: float = 20.0

func _ready():
	add_to_group("energy")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("add_stamina"):
			body.add_stamina(stamina_amount)

		emit_signal("picked_up")
		queue_free()

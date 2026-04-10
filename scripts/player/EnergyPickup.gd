extends Area2D

@export var stamina_amount: int = 20

func _ready():
	add_to_group("energy")
	z_index = 100
	print("Energy muncul di:", global_position)
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("KENA SESUATU:", body)
	print("GROUP:", body.is_in_group("player"))
	print("ADA METHOD:", body.has_method("add_stamina"))

	if body.is_in_group("player") and body.has_method("add_stamina"):
		print("PLAYER KENA ENERGY!")
		body.add_stamina(stamina_amount)
		queue_free()

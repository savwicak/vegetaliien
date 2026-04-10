extends Area2D

@export var spawn_point_path: NodePath  # Drag Marker2D di Inspector
@export var timeline_name: String = "to_pemukiman"

signal spawner_pemukiman

var player_ref: Node2D = null
var dialog_started := false
var spawn_point: Marker2D

func _ready():
	spawn_point = get_node(spawn_point_path)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") and not dialog_started:
		dialog_started = true
		player_ref = body
		
		# Nonaktifkan pergerakan player selama dialog
		if player_ref.has_method("set_physics_process"):
			player_ref.set_physics_process(false)
		
		start_dialog()

func start_dialog():
	# Hubungkan signal dari Dialogic
	if not Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.connect(_on_dialogic_signal)
	
	if not Dialogic.timeline_ended.is_connected(_on_dialog_finished):
		Dialogic.timeline_ended.connect(_on_dialog_finished)

	Dialogic.start(timeline_name)

func _on_dialogic_signal(argument: String):
	if argument == "go_to_pemukiman":
		teleport_player()

func teleport_player():
	if player_ref and spawn_point:
		player_ref.global_position = spawn_point.global_position
	emit_signal("spawner_pemukiman")

func _on_dialog_finished():
	# Aktifkan kembali pergerakan player
	if player_ref:
		player_ref.set_physics_process(true)
	
	dialog_started = false

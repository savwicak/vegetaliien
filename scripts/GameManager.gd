extends Node2D

# ==========================================================
# ENUM STATE GAME
# ==========================================================
enum GameState {
	TUTORIAL,
	STORY,
	PLAYING
}

var current_state = GameState.TUTORIAL
var tutorial_started = false

# Gunakan @onready agar node sudah berada di scene tree
@onready var trigger = get_node_or_null("../scenes/enemy/enemy_animal.gd")

@export var timeline_name: String = "tutorial"

# ==========================================================
# READY
# ==========================================================
func _ready():
	# Hubungkan signal hanya sekali saat node siap
	if trigger:
		if not trigger.tutorial_done.is_connected(_on_tutorial_done):
			trigger.tutorial_done.connect(_on_tutorial_done)
			print("Signal tutorial_done berhasil dihubungkan!")
	else:
		push_warning("Trigger tidak ditemukan! Pastikan path '../Trigger' benar.")

	# Jalankan tutorial saat game dimulai
	start_tutorial()

# ==========================================================
# MENJALANKAN TUTORIAL
# ==========================================================
func start_tutorial():
	if not tutorial_started:
		tutorial_started = true
		current_state = GameState.TUTORIAL
		print("Memulai tutorial...")
		Dialogic.start(timeline_name)

# ==========================================================
# MENERIMA SIGNAL DARI TRIGGER
# ==========================================================
func _on_tutorial_done():
	print("Tutorial selesai!")
	current_state = GameState.PLAYING
	start_game()

# ==========================================================
# MEMULAI GAME SETELAH TUTORIAL
# ==========================================================
func start_game():
	print("Game dimulai! Enemy sekarang bisa aktif.")

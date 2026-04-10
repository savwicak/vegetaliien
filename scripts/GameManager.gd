extends Node2D

enum GameState {
	TUTORIAL,
	STORY,
	PLAYING
}

var current_state = GameState.TUTORIAL
var tutorial_started = false

@export var timeline_name: String = "tutorial"

func _process(delta):
	match current_state:
		GameState.TUTORIAL:
			if !tutorial_started:
				run_tutorial()
				tutorial_started = true

func run_tutorial():
	Dialogic.start(timeline_name)

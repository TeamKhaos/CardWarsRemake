extends Label

@export var game_manager: Node

func _process(_delta):
	if game_manager and game_manager.turn_timer and not game_manager.turn_timer.is_stopped():
		text = "Tiempo: " + str(int(game_manager.turn_timer.time_left))
	else:
		text = "Tiempo: --"


extends Node2D

@export var is_player_one: bool = true

func _ready() -> void:
	var tamano_ventana = get_viewport().size
	if is_player_one:
		self.position = Vector2(tamano_ventana.x * 0.87, tamano_ventana.y * 0.82)
	else:
		self.position = Vector2(tamano_ventana.x * 0.14, tamano_ventana.y * 0.18)

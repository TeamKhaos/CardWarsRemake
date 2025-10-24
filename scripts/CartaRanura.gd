extends Node2D

var carta_en_ranura = false

@export var is_player_one: bool = true
func _ready() -> void:
	var tamano_ventana = get_viewport().size
	if is_player_one:
		self.position = Vector2(tamano_ventana.x * 0.58, tamano_ventana.y * 0.5)
	else:
		self.position = Vector2(tamano_ventana.x * 0.42, tamano_ventana.y * 0.5)
	

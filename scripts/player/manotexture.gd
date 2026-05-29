extends Node2D

@export var is_player_one: bool = true

func _ready() -> void:
	# Pequeña espera para asegurar que el viewport esté listo
	await get_tree().process_frame
	var tamano_ventana = get_viewport_rect().size
	
	if is_player_one:
		self.position = Vector2(tamano_ventana.x * 0.44, tamano_ventana.y * 0.82)
	else:
		self.position = Vector2(tamano_ventana.x * 0.5652, tamano_ventana.y * 0.18)

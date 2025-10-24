extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tamano_ventana = get_viewport().size
	self.position = Vector2(tamano_ventana.x * 0.5, tamano_ventana.y * 0.18)

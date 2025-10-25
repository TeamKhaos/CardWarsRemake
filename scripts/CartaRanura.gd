extends Node2D
var carta_en_ranura = false


@export var primersloot: bool = true
func _ready() -> void:
	var tamano_ventana = get_viewport().size
	if primersloot:
		self.position = Vector2(tamano_ventana.x * 0.418, tamano_ventana.y * 0.5)
	else:
		self.position = Vector2(tamano_ventana.x * 0.582, tamano_ventana.y * 0.5)
		
		
	

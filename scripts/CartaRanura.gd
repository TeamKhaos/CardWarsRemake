extends Node2D

@export var id_ranura: String = ""
@export var primersloot: bool = true
var carta_en_ranura = false

func _ready() -> void:
	var tamano_ventana = get_viewport().size
	if primersloot:
		self.position = Vector2(tamano_ventana.x * 0.418, tamano_ventana.y * 0.5)
		id_ranura = "ranuraplayer"
	else:
		self.position = Vector2(tamano_ventana.x * 0.582, tamano_ventana.y * 0.5)
		id_ranura = "ranuraia"
	
	set_meta("id_ranura", id_ranura)
	set_meta("es_ia", !primersloot)
	set_meta("carta_en_ranura", carta_en_ranura)

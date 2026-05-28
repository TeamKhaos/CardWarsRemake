extends Node2D

@export var es_ia: bool = false # Si este contenedor es para la IA o el Jugador

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	posicionar_ranuras()

func posicionar_ranuras() -> void:
	var tamano_ventana = get_viewport_rect().size
	
	# Las 5 letras que pidió el usuario
	var letras = ["k", "h", "a", "o", "s"]
	
	# Buscamos los hijos llamados Ranura1, Ranura2, etc.
	var ranuras = [
		get_node_or_null("Ranura1"),
		get_node_or_null("Ranura2"),
		get_node_or_null("Ranura3"),
		get_node_or_null("Ranura4"),
		get_node_or_null("Ranura5")
	]
	
	# Configuración de posicionamiento
	# Queremos que estén centradas horizontalmente
	var margen_h = 0.15 # 15% de margen a los lados
	var y_pos = tamano_ventana.y * 0.6 if !es_ia else tamano_ventana.y * 0.4
	var area_disponible = tamano_ventana.x * (1.0 - (margen_h * 2))
	var spacing = area_disponible / (ranuras.size() - 1)
	
	var prefix = "ranuraia" if es_ia else "ranuraplayer"
	
	for i in range(ranuras.size()):
		var ranura = ranuras[i]
		if ranura:
			# Posicionamiento horizontal
			var x_pos = (tamano_ventana.x * margen_h) + (spacing * i)
			ranura.global_position = Vector2(x_pos, y_pos)
			
			# Asignar ID según la letra correspondiente
			ranura.id_ranura = prefix + letras[i]
			ranura.es_ia = es_ia
			
			print("📍 Ranura ", letras[i], " posicionada en: ", ranura.global_position, " ID: ", ranura.id_ranura)

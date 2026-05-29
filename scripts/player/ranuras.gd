extends Node2D

@export var is_player_one: bool = true

func _ready() -> void:
	# Inicializamos inmediatamente para garantizar que las ranuras existan para los Decks
	inicializar_ranuras_khaos()

func inicializar_ranuras_khaos() -> void:
	var tamano_ventana = get_viewport_rect().size
	

	# Posicionar el contenedor según el jugador
	if is_player_one:
		self.position = Vector2(tamano_ventana.x * 0.445, tamano_ventana.y * 0.82)
	else:
		self.position = Vector2(tamano_ventana.x * 0.555, tamano_ventana.y * 0.18)

	var letras = ["K", "H", "A", "O", "S"]
	# Espaciado ajustado para escala 1.0
	var spacing = 170.0 
	
	print("📍 [RANURAS] Inicializando letras KHAOS para ", "Jugador" if is_player_one else "IA")
	
	for i in range(letras.size()):
		var nodo = get_node_or_null(letras[i])
		if nodo:
	
			# Alinear horizontalmente
			nodo.position = Vector2((i - 2) * spacing, 0)
			
			# ASEGURAR QUE LAS LETRAS ESTÉN AL FONDO
			nodo.z_index = 0
			
			# --- HACER QUE EL NODO FUNCIONE COMO RANURA ---
			
			# 1. Añadir variables necesarias usando Metadata
			var prefix = "ranuraplayer" if is_player_one else "ranuraia"
			var id_final = prefix + letras[i].to_lower()
			
			nodo.set_meta("id_ranura", id_final)
			nodo.set_meta("es_ia", !is_player_one)
			nodo.set_meta("carta_en_ranura", false)
			
			# 2. Añadir al grupo
			if not nodo.is_in_group("ranuras"):
				nodo.add_to_group("ranuras")
			
			# 3. Crear Area2D y Colisión
			var area = nodo.get_node_or_null("AreaRanura")
			if not area:
				area = Area2D.new()
				area.name = "AreaRanura"
				area.collision_layer = 2
				area.collision_mask = 0
				nodo.add_child(area)
				
				var shape = CollisionShape2D.new()
				var rect = RectangleShape2D.new()
				rect.size = Vector2(300, 500) 
				shape.shape = rect
				area.add_child(shape)
			
			print("✅ Ranura ", letras[i], " lista en ID: ", nodo.get_meta("id_ranura"))

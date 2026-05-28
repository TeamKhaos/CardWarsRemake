extends Node2D

@export var is_player_one: bool = true
@export var manejo_carta: Node
@export var manejo_jugador: Node

# --- VARIABLES ---
var jugador_deck = []
const carta_escena_dir = "res://scenes/card.tscn"
const velocidad_reparto = 0.5
var primerclick = false
var referencia_db_cartas

# --- FUNCIONES DE GODOT ---
func _ready() -> void:
	var tamano_ventana = get_viewport().size
	if is_player_one:
		self.position = Vector2(tamano_ventana.x * 0.20, tamano_ventana.y * 0.82)
	else:
		self.position = Vector2(tamano_ventana.x * 0.80, tamano_ventana.y * 0.18)

	var DbCartas = preload("res://scripts/DB_Cartas.gd")
	if not DbCartas:
		print("❌ [DECK] ERROR: No se pudo cargar DB_Cartas.gd")
		return
	
	jugador_deck = DbCartas.CARTAS.keys()
	jugador_deck.shuffle()
	
	$RichTextLabel.text = str(jugador_deck.size())
	referencia_db_cartas = DbCartas
	
	# Repartir cartas automáticamente un poco después para dar tiempo a las ranuras
	await get_tree().create_timer(0.1).timeout
	repartir_a_ranuras()

func repartir_a_ranuras():
	print("🎴 [DECK] Iniciando reparto automático...")
	if primerclick: 
		print("🎴 [DECK] El reparto ya se había ejecutado.")
		return
	primerclick = true
	
	# 1. Obtener las ranuras del jugador (letras K, H, A, O, S)
	var ranuras_libres = []
	var nodos_ranuras = get_tree().get_nodes_in_group("ranuras")
	print("🎴 [DECK] Ranuras encontradas en grupo 'ranuras': ", nodos_ranuras.size())
	
	# Necesitamos asegurar que las ranuras estén ordenadas K, H, A, O, S
	var orden_letras = ["k", "h", "a", "o", "s"]
	var prefijo = "ranuraplayer" if is_player_one else "ranuraia"
	
	for letra in orden_letras:
		var id_buscado = prefijo + letra
		var encontrado = false
		for r in nodos_ranuras:
			var id_actual = r.get_meta("id_ranura", "")
			if id_actual == id_buscado:
				ranuras_libres.append(r)
				encontrado = true
				break
		if not encontrado:
			print("⚠️ [DECK] No se encontró la ranura con ID: ", id_buscado)
	
	print("🎴 [DECK] Ranuras listas para recibir cartas: ", ranuras_libres.size())
	
	# 2. Repartir una carta a cada ranura
	for i in range(min(ranuras_libres.size(), jugador_deck.size())):
		var ranura = ranuras_libres[i]
		
		var carta_nombre = jugador_deck[0]
		jugador_deck.erase(carta_nombre)
		$RichTextLabel.text = str(jugador_deck.size())
		
		print("🎴 [DECK] Repartiendo ", carta_nombre, " a ", ranura.get_meta("id_ranura"))
		
		# Crear la carta
		var carta_escena = preload(carta_escena_dir)
		var nueva_carta = carta_escena.instantiate()
		nueva_carta.global_position = self.global_position
		nueva_carta.scale = Vector2(0.7, 0.7) # Escala inicial correcta
		
		# Asegurar orientación (0 grados para jugador)
		nueva_carta.rotation = 0
		
		# Configurar datos
		var datos = referencia_db_cartas.CARTAS[carta_nombre]
		nueva_carta.set_meta("ataque", datos["ataque"])
		nueva_carta.set_meta("tipo", datos["tipo"])
		nueva_carta.aplicar_brillo_elemental(datos["tipo"])
		
		var img_path = "res://assets/" + carta_nombre + ".png"
		nueva_carta.get_node("Cardimage").texture = load(img_path)
		
		manejo_carta.add_child(nueva_carta)
		
		# Animar "caída" a la ranura
		var tween = create_tween()
		tween.tween_property(nueva_carta, "global_position", ranura.global_position, velocidad_reparto).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(nueva_carta, "scale", Vector2(0.7, 0.7), velocidad_reparto)
		
		# Al terminar la animación, registrar en GameManager
		finalizar_reparto_carta(nueva_carta, ranura)
		
		# Pequeño retraso entre cartas para que no salgan todas a la vez
		await get_tree().create_timer(0.2).timeout

	print("🎴 [DECK] Reparto finalizado.")
	
	var gm_nodes = get_tree().get_nodes_in_group("game_manager")
	if gm_nodes.size() > 0:
		# Aquí pasamos 'false' para indicar que es el jugador, no la IA
		gm_nodes[0].senal_reparto_terminado(false)

func finalizar_reparto_carta(carta, ranura):
	ranura.set_meta("carta_en_ranura", true)
	
	# Mantenemos la colisión activa
	carta.get_node("Area2D/CollisionShape2D").disabled = false
	
	# Registro en el manager
	var gm_nodes = get_tree().get_nodes_in_group("game_manager")
	if gm_nodes.size() > 0:
		var id = ranura.get_meta("id_ranura")
		print("🎴 [DECK] Registrando ", carta.name, " en ID: ", id)
		# 'false' porque es el jugador
		gm_nodes[0].registrar_carta(id, carta, false)

# --- MANTENER COMPATIBILIDAD ---
func tomar_carta_inicial():
	pass # Reemplazada por repartir_a_ranuras

func reponer_carta():
	# Si una ranura se queda vacía después de un combate, se podría llamar a esto
	# para rellenar ese carril específico.
	pass

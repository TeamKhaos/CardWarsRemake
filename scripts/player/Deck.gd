extends Node2D

@export var is_player_one: bool = true
@export var manejo_carta: Node
@export var manejo_jugador: Node

# --- VARIABLES ---
const DECK_AURA_SHADER = preload("res://assets/shaders/deck_aura.gdshader")
var jugador_deck = []
const carta_escena_dir = "res://scenes/card.tscn"
const velocidad_reparto = 0.5
var primerclick = false
var referencia_db_cartas

# --- FUNCIONES DE GODOT ---
func _ready() -> void:
	add_to_group("player_deck")
	var tamano_ventana = get_viewport().size
	if is_player_one:
		self.position = Vector2(tamano_ventana.x * 0.10, tamano_ventana.y * 0.82)
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
	
	# Aplicar shader de aura al mazo
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		var mat = ShaderMaterial.new()
		mat.shader = DECK_AURA_SHADER
		mat.set_shader_parameter("aura_color", Color(0.2, 0.6, 1.0, 0.6)) # Azul místico
		mat.set_shader_parameter("aura_width", 0.04)
		mat.set_shader_parameter("speed", 1.5)
		mat.set_shader_parameter("intensity", 0.4)
		sprite.material = mat
	
	# Repartir cartas automáticamente un poco después para dar tiempo a las ranuras
	await get_tree().create_timer(0.1).timeout
	repartir_a_ranuras()
	
	# Conectar el temporizador si existe en la escena
	var temporizador = get_tree().root.find_child("Temporizador", true, false)
	if temporizador:
		temporizador.tiempo_agotado.connect(_on_timer_timeout_auto_play)
		temporizador.iniciar_cuenta_regresiva()

func _on_timer_timeout_auto_play():
	print("🃏 [DECK] Tiempo agotado. Eligiendo carta automática para el jugador...")
	jugar_carta_aleatoria()

func jugar_carta_aleatoria():
	# 1. Buscar una carta disponible en las ranuras KHAOS
	var cartas_disponibles = []
	var ranuras_ocupadas = []
	
	var todas_las_ranuras = get_tree().get_nodes_in_group("ranuras")
	print("🔍 [DECK] Buscando cartas en ", todas_las_ranuras.size(), " ranuras totales.")
	
	for r in todas_las_ranuras:
		var id = r.get_meta("id_ranura", "")
		if id.begins_with("ranuraplayer") and id != "ranuraplayer":
			var ocupada = r.get_meta("carta_en_ranura", false)
			var nodo_carta = r.get_meta("carta_en_ranura_node", null)
			
			print("   - Ranura: ", id, " | Ocupada meta: ", ocupada, " | Nodo: ", "OK" if nodo_carta else "NULO")
			
			if ocupada and is_instance_valid(nodo_carta):
				cartas_disponibles.append(nodo_carta)
				ranuras_ocupadas.append(r)
	
	if cartas_disponibles.size() == 0:
		print("⚠️ [DECK] No hay cartas disponibles para jugar automáticamente.")
		return

	# 2. Elegir una al azar
	var indice = randi() % cartas_disponibles.size()
	var carta_elegida = cartas_disponibles[indice]
	var ranura_origen = ranuras_ocupadas[indice]
	
	# 3. Buscar la ranura central del jugador
	var ranura_central = null
	for r in todas_las_ranuras:
		if r.get_meta("id_ranura", "") == "ranuraplayer":
			ranura_central = r
			break
	
	if carta_elegida and ranura_central:
		# Si la ranura central está ocupada, no hacemos nada (o podríamos hacer swap, pero mejor no arriesgar)
		if ranura_central.get_meta("carta_en_ranura", false):
			print("⚠️ [DECK] Ranura central ocupada, no se puede jugar automáticamente.")
			return

		print("🃏 [DECK] Jugando automáticamente: ", carta_elegida.name, " desde ", ranura_origen.get_meta("id_ranura"))
		
		# Liberar origen
		ranura_origen.set_meta("carta_en_ranura", false)
		ranura_origen.set_meta("carta_en_ranura_node", null)
		
		# Ocupar destino
		ranura_central.set_meta("carta_en_ranura", true)
		ranura_central.set_meta("carta_en_ranura_node", carta_elegida)
		
		# Bloquear carta (como si el jugador la hubiera arrastrado)
		if carta_elegida.has_node("Area2D"):
			carta_elegida.get_node("Area2D").input_pickable = false
		
		# Registrar en el GameManager
		var gm_nodes = get_tree().get_nodes_in_group("game_manager")
		if gm_nodes.size() > 0:
			gm_nodes[0].registrar_carta("ranuraplayer", carta_elegida, false)
		
		# Animación al centro
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_QUART)
		tween.tween_property(carta_elegida, "global_position", ranura_central.global_position, 0.5)
		
		# Reponer la ranura que quedó vacía
		reponer_carta_en_ranura(ranura_origen)

func repartir_a_ranuras():
	print("🎴 [DECK] Iniciando reparto visual a K-H-A-O-S...")
	if primerclick: return
	primerclick = true

	# 1. Obtener las ranuras de la mano (K, H, A, O, S)
	var nodos_mano = get_tree().get_nodes_in_group("ranuras")
	var ranuras_jugador = []
	
	var orden_letras = ["k", "h", "a", "o", "s"]
	for letra in orden_letras:
		var id_buscado = "ranuraplayer" + letra
		for r in nodos_mano:
			if r.get_meta("id_ranura", "") == id_buscado:
				ranuras_jugador.append(r)
				break

	# 2. Repartir
	for i in range(min(ranuras_jugador.size(), jugador_deck.size())):
		var ranura = ranuras_jugador[i]
		var carta_nombre = jugador_deck[0]
		jugador_deck.erase(carta_nombre)
		
		# --- CORRECCIÓN: ACTUALIZAR UI ---
		$RichTextLabel.text = str(jugador_deck.size())

		# Crear la carta
		var carta_escena = preload(carta_escena_dir)
		var nueva_carta = carta_escena.instantiate()
		nueva_carta.global_position = self.global_position
		nueva_carta.scale = Vector2(0.7, 0.7)
		nueva_carta.rotation_degrees = 0

		# Configurar datos
		var datos = referencia_db_cartas.CARTAS[carta_nombre]
		nueva_carta.set_meta("ataque", datos["ataque"])
		nueva_carta.set_meta("tipo", datos["tipo"])
		nueva_carta.aplicar_brillo_elemental(datos["tipo"])
		nueva_carta.get_node("Cardimage").texture = load("res://assets/" + carta_nombre + ".png")

		# Forzar boca arriba y rotación 0
		if nueva_carta.has_method("flip_face_up"):
			nueva_carta.flip_face_up()

		manejo_carta.add_child(nueva_carta)
		
		# --- REGISTRO CRÍTICO EN RANURA ---
		ranura.set_meta("carta_en_ranura", true)
		ranura.set_meta("carta_en_ranura_node", nueva_carta)

		# Animar a la ranura de la mano
		var tween = create_tween()
		tween.tween_property(nueva_carta, "global_position", ranura.global_position, velocidad_reparto).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

		await get_tree().create_timer(0.1).timeout

	print("🎴 [DECK] Reparto visual finalizado.")
	
	var gm_nodes = get_tree().get_nodes_in_group("game_manager")
	if gm_nodes.size() > 0:
		gm_nodes[0].senal_reparto_terminado(false)

# --- MANTENER COMPATIBILIDAD ---
func tomar_carta_inicial():
	pass # Reemplazada por repartir_a_ranuras

func reponer_carta_en_ranura(ranura):
	print("DEBUG: Entrando en reponer_carta_en_ranura para: ", ranura.get_meta("id_ranura", ""))
	if jugador_deck.size() == 0:
		print("⚠️ [DECK] No hay más cartas en el mazo.")
		return
	
	var carta_nombre = jugador_deck[0]
	jugador_deck.erase(carta_nombre)
	$RichTextLabel.text = str(jugador_deck.size())

	# Crear la carta
	var carta_escena = preload(carta_escena_dir)
	var nueva_carta = carta_escena.instantiate()
	nueva_carta.global_position = self.global_position
	nueva_carta.scale = Vector2(0.7, 0.7)
	
	# Configurar datos
	var datos = referencia_db_cartas.CARTAS[carta_nombre]
	nueva_carta.set_meta("ataque", datos["ataque"])
	nueva_carta.set_meta("tipo", datos["tipo"])
	nueva_carta.aplicar_brillo_elemental(datos["tipo"])
	nueva_carta.get_node("Cardimage").texture = load("res://assets/" + carta_nombre + ".png")
	nueva_carta.flip_face_up()

	manejo_carta.add_child(nueva_carta)

	# Animar a la ranura vacía
	var tween = create_tween()
	tween.tween_property(nueva_carta, "global_position", ranura.global_position, velocidad_reparto).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	# Marcar ranura como ocupada
	ranura.set_meta("carta_en_ranura", true)
	ranura.set_meta("carta_en_ranura_node", nueva_carta)

	print("🎴 [DECK] Carta repuesta en ranura: ", ranura.get_meta("id_ranura"))

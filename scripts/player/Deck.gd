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
	add_to_group("player_deck")
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
	print("🎴 [DECK] Iniciando reparto visual a K-H-A-O-S...")
	if primerclick: return
	primerclick = true

	# 1. Obtener las ranuras de la mano (K, H, A, O, S)
	var nodos_mano = get_tree().get_nodes_in_group("ranuras")
	var ranuras_jugador = []
	for r in nodos_mano:
		if r.get_meta("id_ranura", "").begins_with("ranuraplayer") and r.get_meta("id_ranura", "") != "ranuraplayer":
			ranuras_jugador.append(r)

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

		# Animar a la ranura de la mano
		var tween = create_tween()
		tween.tween_property(nueva_carta, "global_position", ranura.global_position, velocidad_reparto).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

		await get_tree().create_timer(0.1).timeout

	print("🎴 [DECK] Reparto visual finalizado.")

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

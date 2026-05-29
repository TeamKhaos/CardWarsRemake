extends Node2D

@export var is_player_one: bool = false
@export var manejo_carta: Node
@export var manejo_ia: Node

# --- VARIABLES ---
var ia_deck = []
const carta_escena_dir = "res://scenes/card.tscn"
const velocidad_reparto = 0.5
var referencia_db_cartas

# --- FUNCIONES DE GODOT ---
func _ready() -> void:
	add_to_group("deck_ia")
	var tamano_ventana = get_viewport().size
	if is_player_one:
		self.position = Vector2(tamano_ventana.x * 0.20, tamano_ventana.y * 0.82)
	else:
		self.position = Vector2(tamano_ventana.x * 0.80, tamano_ventana.y * 0.18)
	
	var DbCartas = preload("res://scripts/DB_Cartas.gd")
	if not DbCartas:
		print("❌ [DECK-AI] ERROR: No se pudo cargar DB_Cartas.gd")
		return
		
	referencia_db_cartas = DbCartas
	ia_deck = DbCartas.CARTAS.keys()
	ia_deck.shuffle()
	
	# Repartir automáticamente un poco después
	await get_tree().create_timer(0.1).timeout
	repartir_a_ranuras_ia()

func repartir_a_ranuras_ia():
	print("🤖 [DECK-AI] Iniciando reparto automático IA...")
	
	# 1. Obtener las ranuras de la IA (K, H, A, O, S)
	var ranuras_libres = []
	var nodos_ranuras = get_tree().get_nodes_in_group("ranuras")
	print("🤖 [DECK-AI] Ranuras totales en grupo 'ranuras': ", nodos_ranuras.size())
	
	var orden_letras = ["k", "h", "a", "o", "s"]
	var prefijo = "ranuraia"
	
	for letra in orden_letras:
		var id_buscado = prefijo + letra
		var encontrado = false
		for r in nodos_ranuras:
			if r.get_meta("id_ranura", "") == id_buscado:
				ranuras_libres.append(r)
				encontrado = true
				break
		if not encontrado:
			print("⚠️ [DECK-AI] No se encontró ranura IA: ", id_buscado)
	
	# 2. Repartir una carta a cada ranura KHAOS
	for i in range(min(ranuras_libres.size(), ia_deck.size())):
		var ranura = ranuras_libres[i]
		if ranura.get_meta("carta_en_ranura", false): continue
		
		var carta_nombre = ia_deck.pop_front()
		
		# --- ACTUALIZAR CONTADOR ---
		if has_node("RichTextLabel"):
			$RichTextLabel.text = str(ia_deck.size())
		
		# --- MISMO CÓDIGO DE INSTANCIACIÓN DE ANTES ---
		var carta_escena = preload(carta_escena_dir)
		var nueva_carta = carta_escena.instantiate()
		nueva_carta.is_ai = true
		nueva_carta.global_position = self.global_position
		nueva_carta.scale = Vector2(0.7, 0.7)
		
		var datos = referencia_db_cartas.CARTAS[carta_nombre]
		nueva_carta.set_meta("ataque", datos["ataque"])
		nueva_carta.set_meta("tipo", datos["tipo"])
		nueva_carta.aplicar_brillo_elemental(datos["tipo"], true)
		
		var img_path = "res://assets/" + carta_nombre + ".png"
		nueva_carta.get_node("Cardimage").texture = load(img_path)
		
		manejo_carta.add_child(nueva_carta)
		
		var tween = create_tween()
		tween.tween_property(nueva_carta, "global_position", ranura.global_position, velocidad_reparto).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		
		ranura.set_meta("carta_en_ranura", true)
		nueva_carta.get_node("Area2D/CollisionShape2D").disabled = true
		
		var gm_nodes = get_tree().get_nodes_in_group("game_manager")
		if gm_nodes.size() > 0:
			gm_nodes[0].registrar_carta(ranura.get_meta("id_ranura"), nueva_carta, true)
		
		await get_tree().create_timer(0.1).timeout

	# --- NUEVO: REPARTIR A RANURAIA ---
	print("🤖 [DECK-AI] Repartiendo carta a ranuraia...")
	var ranura_central = null
	for r in nodos_ranuras:
		if r.get_meta("id_ranura", "") == "ranuraia":
			ranura_central = r
			break
			
	if ranura_central and ia_deck.size() > 0:
		var carta_nombre = ia_deck.pop_front()
		var carta_escena = preload(carta_escena_dir)
		var nueva_carta = carta_escena.instantiate()
		nueva_carta.is_ai = true
		nueva_carta.global_position = self.global_position
		nueva_carta.scale = Vector2(0.7, 0.7)
		
		var datos = referencia_db_cartas.CARTAS[carta_nombre]
		nueva_carta.set_meta("ataque", datos["ataque"])
		nueva_carta.set_meta("tipo", datos["tipo"])
		nueva_carta.aplicar_brillo_elemental(datos["tipo"], true)
		nueva_carta.get_node("Cardimage").texture = load("res://assets/" + carta_nombre + ".png")
		
		manejo_carta.add_child(nueva_carta)
		
		var tween = create_tween()
		tween.tween_property(nueva_carta, "global_position", ranura_central.global_position, velocidad_reparto).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		
		var gm_nodes = get_tree().get_nodes_in_group("game_manager")
		if gm_nodes.size() > 0:
			gm_nodes[0].registrar_carta("ranuraia", nueva_carta, true)
	
	print("🤖 [DECK-AI] Reparto IA finalizado.")
	
	var gm_nodes = get_tree().get_nodes_in_group("game_manager")
	if gm_nodes.size() > 0:
		gm_nodes[0].senal_reparto_terminado(true)

# --- MANTENER COMPATIBILIDAD ---
func tomar_carta():
	if ia_deck.size() == 0:
		print("🤖 [DECK-AI] No quedan cartas en el mazo.")
		return
	
	var carta_nombre = ia_deck.pop_front()
	if has_node("RichTextLabel"):
		$RichTextLabel.text = str(ia_deck.size())
		
	var carta_escena = preload(carta_escena_dir)
	var nueva_carta = carta_escena.instantiate()
	nueva_carta.is_ai = true
	nueva_carta.scale = Vector2(0.7, 0.7)
	
	var datos = referencia_db_cartas.CARTAS[carta_nombre]
	nueva_carta.set_meta("ataque", datos["ataque"])
	nueva_carta.set_meta("tipo", datos["tipo"])
	
	# La IA oculta su carta al inicio
	nueva_carta.aplicar_brillo_elemental(datos["tipo"], true)
	
	var img_path = "res://assets/" + carta_nombre + ".png"
	nueva_carta.get_node("Cardimage").texture = load(img_path)
	
	manejo_carta.add_child(nueva_carta)
	manejo_ia.añadir_carta_mano(nueva_carta, 0.2)
	print("🤖 [DECK-AI] Carta tomada: ", carta_nombre)

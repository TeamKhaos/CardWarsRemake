extends Node2D

@export var is_player_one: bool = false
@export var manejo_carta: Node

# --- VARIABLES ---
const DECK_AURA_SHADER = preload("res://assets/shaders/deck_aura.gdshader")
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
		self.position = Vector2(tamano_ventana.x * 0.90, tamano_ventana.y * 0.18)
	
	var DbCartas = preload("res://scripts/DB_Cartas.gd")
	if not DbCartas:
		print("❌ [DECK-AI] ERROR: No se pudo cargar DB_Cartas.gd")
		return
		
	referencia_db_cartas = DbCartas
	ia_deck = DbCartas.CARTAS.keys()
	ia_deck.shuffle()
	
	# Aplicar shader de aura al mazo de la IA
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		var mat = ShaderMaterial.new()
		mat.shader = DECK_AURA_SHADER
		mat.set_shader_parameter("aura_color", Color(0.8, 0.2, 0.2, 0.6)) # Rojo amenazante para la IA
		mat.set_shader_parameter("aura_width", 0.04)
		mat.set_shader_parameter("speed", 1.5)
		mat.set_shader_parameter("intensity", 0.4)
		sprite.material = mat
	
	# Repartir automáticamente un poco después
	await get_tree().create_timer(0.1).timeout
	repartir_a_ranuras_ia()

func repartir_a_ranuras_ia():
	print("🤖 [DECK-AI] Iniciando reparto automático IA...")
	
	var ranuras_libres = []
	var nodos_ranuras = get_tree().get_nodes_in_group("ranuras")
	
	var orden_letras = ["k", "h", "a", "o", "s"]
	var prefijo = "ranuraia"
	
	for letra in orden_letras:
		var id_buscado = prefijo + letra
		for r in nodos_ranuras:
			if r.get_meta("id_ranura", "") == id_buscado:
				ranuras_libres.append(r)
				break
	
	for i in range(min(ranuras_libres.size(), ia_deck.size())):
		var ranura = ranuras_libres[i]
		reponer_carta_en_ranura(ranura)
		await get_tree().create_timer(0.1).timeout

	# Repartir a ranura central de la IA (combate central)
	var ranura_central = null
	for r in nodos_ranuras:
		if r.get_meta("id_ranura", "") == "ranuraia":
			ranura_central = r
			break
			
	if ranura_central:
		reponer_carta_en_ranura(ranura_central)
	
	print("🤖 [DECK-AI] Reparto IA finalizado.")
	
	var gm_nodes = get_tree().get_nodes_in_group("game_manager")
	if gm_nodes.size() > 0:
		gm_nodes[0].senal_reparto_terminado(true)

func reponer_carta_en_ranura(ranura):
	if ia_deck.size() == 0:
		print("🤖 [DECK-AI] No hay más cartas en el mazo IA.")
		return
	
	var carta_nombre = ia_deck.pop_front()
	if has_node("RichTextLabel"):
		$RichTextLabel.text = str(ia_deck.size())

	var carta_escena = preload(carta_escena_dir)
	var nueva_carta = carta_escena.instantiate()
	nueva_carta.is_ai = true
	nueva_carta.global_position = self.global_position
	# Forzar escala de 'hover' (0.8) para la IA
	nueva_carta.scale = Vector2(0.8, 0.8)
	
	var datos = referencia_db_cartas.CARTAS[carta_nombre]
	nueva_carta.set_meta("ataque", datos["ataque"])
	nueva_carta.set_meta("tipo", datos["tipo"])
	nueva_carta.aplicar_brillo_elemental(datos["tipo"], true)
	nueva_carta.get_node("Cardimage").texture = load("res://assets/" + carta_nombre + ".png")
	
	manejo_carta.add_child(nueva_carta)
	
	var tween = create_tween()
	tween.tween_property(nueva_carta, "global_position", ranura.global_position, velocidad_reparto).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	ranura.set_meta("carta_en_ranura", true)
	ranura.set_meta("carta_en_ranura_node", nueva_carta)
	
	# Deshabilitar interacción
	if nueva_carta.has_node("Area2D/CollisionShape2D"):
		nueva_carta.get_node("Area2D/CollisionShape2D").disabled = true
	
	var gm_nodes = get_tree().get_nodes_in_group("game_manager")
	if gm_nodes.size() > 0:
		gm_nodes[0].registrar_carta(ranura.get_meta("id_ranura"), nueva_carta, true)

func tomar_carta():
	# Mantenemos por compatibilidad, pero redirigimos a una ranura vacía si es posible
	var ranuras = get_tree().get_nodes_in_group("ranuras")
	for r in ranuras:
		if r.get_meta("id_ranura", "").begins_with("ranuraia") and not r.get_meta("carta_en_ranura", false):
			reponer_carta_en_ranura(r)
			return

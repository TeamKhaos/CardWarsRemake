
extends Node2D

@export var is_player_one: bool = true
@export var manejo_jugador: Node
@export var input_manager: Node
@export var game_manager: Node
@export var slots_container: Node

# --- VARIABLES ---
var carta_siend_arrastrada
var tamano_escena
const MASCARA_COLISION_CARTA = 1
const MASCARA_COLISION_CARTA_RANURA = 2
const velocidad_de_carta_default = 0.2
var ALTURA_DEFECTO_CARTA: float
var ALTURA_SUBIDA_CARTA: float

var cursor_sobre_carta
var mano_jugador_referencia
var ultima_posicion_mouse: Vector2 = Vector2.ZERO
var velocidad_suavizada: Vector2 = Vector2.ZERO

# --- FUNCIONES DE GODOT ---
func _ready() -> void:
	tamano_escena = get_viewport_rect().size
	mano_jugador_referencia = manejo_jugador
	input_manager.connect("levantado_click_izquierdo", on_click_izquierdo_levantado)

	# Fallback si no está asignado en el inspector
	if not game_manager:
		var gm_nodes = get_tree().get_nodes_in_group("game_manager")
		if gm_nodes.size() > 0:
			game_manager = gm_nodes[0]
			print("✅ Game_Manager encontrado por grupo.")
		else:
			game_manager = get_tree().root.find_child("Game_Manager", true, false)
			if game_manager:
				print("✅ Game_Manager encontrado por find_child.")

	ALTURA_DEFECTO_CARTA = 0.70
	ALTURA_SUBIDA_CARTA = 0.80


func _process(delta: float) -> void:
	if carta_siend_arrastrada:
		var mouse_pos = get_global_mouse_position()
		
		# Calcular velocidad y suavizarla
		var instant_vel = (mouse_pos - ultima_posicion_mouse) / delta
		velocidad_suavizada = velocidad_suavizada.lerp(instant_vel * 0.001, delta * 15.0)
		
		carta_siend_arrastrada.set_drag_velocity(velocidad_suavizada)
		
		ultima_posicion_mouse = mouse_pos
		carta_siend_arrastrada.global_position = Vector2(clamp(mouse_pos.x, 0, tamano_escena.x), clamp(mouse_pos.y, 0, tamano_escena.y))

# --- FUNCIONES DE ARRASTRE ---
func empezar_a_arrastrar(carta):
	carta_siend_arrastrada = carta
	# Guardamos la posición inicial por si el movimiento es inválido
	carta.posicion_inicial = carta.global_position
	carta.scale = Vector2(ALTURA_SUBIDA_CARTA, ALTURA_SUBIDA_CARTA)
	ultima_posicion_mouse = get_global_mouse_position()
	velocidad_suavizada = Vector2.ZERO
	
func dejar_de_arrastrar():
	if carta_siend_arrastrada == null:
		return

	# Resetear visuales
	carta_siend_arrastrada.set_drag_velocity(Vector2.ZERO)
	velocidad_suavizada = Vector2.ZERO

	var ranura_destino = raycast_check_carta_ranura()
	var pos_de_donde_vengo = carta_siend_arrastrada.posicion_inicial

	# Si soltamos en una ranura válida del jugador
	if ranura_destino and ranura_destino.get_meta("id_ranura", "").begins_with("ranuraplayer"):
		
		# 1. Buscar si hay una carta ya puesta en el destino
		var carta_en_destino = null
		for c in get_tree().get_nodes_in_group("cartas"):
			if c != carta_siend_arrastrada and c.global_position.distance_to(ranura_destino.global_position) < 50.0:
				carta_en_destino = c
				break
		
		# 2. Identificar la ranura de origen (si venía de una)
		var ranura_origen = null
		for r in get_tree().get_nodes_in_group("ranuras"):
			if r.global_position.distance_to(pos_de_donde_vengo) < 50.0:
				ranura_origen = r
				break
		
		# --- CASO A: INTERCAMBIO (Swap) ---
		if carta_en_destino:
			if ranura_origen:
				# Movemos la carta que estaba en el destino a nuestra vieja casa
				carta_en_destino.global_position = ranura_origen.global_position
				carta_en_destino.posicion_inicial = ranura_origen.global_position
				
				# Registramos el cambio en el Manager
				registrar_en_manager(ranura_origen.get_meta("id_ranura"), carta_en_destino)
				print("🔄 Intercambio: ", carta_siend_arrastrada.name, " <-> ", carta_en_destino.name)
			else:
				# Si no hay ranura de origen (venía de la mano), devolvemos la arrastrada
				# (Opcional: podrías decidir que la arrastrada se quede y la vieja vuelva a la mano)
				volver_a_casa(carta_siend_arrastrada)
				carta_siend_arrastrada = null
				return

		# --- CASO B: MOVER A RANURA VACÍA ---
		else:
			# Si veníamos de una ranura, liberarla
			if ranura_origen:
				ranura_origen.set_meta("carta_en_ranura", false)

		# Finalizar movimiento de la carta arrastrada al destino
		carta_siend_arrastrada.global_position = ranura_destino.global_position
		carta_siend_arrastrada.posicion_inicial = ranura_destino.global_position
		ranura_destino.set_meta("carta_en_ranura", true)
		# Mantenemos is_in_hand true para que siga moviéndose en la ranura
		carta_siend_arrastrada.is_in_hand = true
		
		# Registrar en GameManager
		registrar_en_manager(ranura_destino.get_meta("id_ranura"), carta_siend_arrastrada)

	else:
		# Si soltamos fuera, vuelve a donde estaba
		volver_a_casa(carta_siend_arrastrada)

	carta_siend_arrastrada = null

func registrar_en_manager(id_r, carta):
	if not game_manager:
		var gm_nodes = get_tree().get_nodes_in_group("game_manager")
		game_manager = gm_nodes[0] if gm_nodes.size() > 0 else null
	
	if game_manager:
		game_manager.registrar_carta(id_r, carta, false)

func volver_a_casa(carta):
	var tween = create_tween()
	tween.tween_property(carta, "global_position", carta.posicion_inicial, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	carta.scale = Vector2(ALTURA_DEFECTO_CARTA, ALTURA_DEFECTO_CARTA)

	
# --- MANEJO DE SEÑALES DE LA CARTA ---
func connect_carta_signal(carta):
	carta.connect("sosteniendo", on_hovered_over_carta)
	carta.connect("soltando", on_hovered_off_carta)
	carta.scale = Vector2(ALTURA_DEFECTO_CARTA, ALTURA_DEFECTO_CARTA)
	
func on_hovered_over_carta(carta):
	if carta.is_ai: return
	if !cursor_sobre_carta:
		cursor_sobre_carta = true 
		resaltar_carta(carta, true)

func on_hovered_off_carta(carta):
	if !carta_siend_arrastrada:
		cursor_sobre_carta = false
		resaltar_carta(carta, false)
		var nueva_carta_sosteniendo = raycast_check_carta()
		if nueva_carta_sosteniendo and nueva_carta_sosteniendo.is_ai: return
		if nueva_carta_sosteniendo:
			resaltar_carta(nueva_carta_sosteniendo, true)
		else:
			cursor_sobre_carta = false

# --- FUNCIONES DE UTILIDAD ---
func resaltar_carta(carta, sosteniendo):
	if sosteniendo:
		carta.scale = Vector2(ALTURA_SUBIDA_CARTA, ALTURA_SUBIDA_CARTA)
		carta.z_index = 2
	else:
		carta.scale = Vector2(ALTURA_DEFECTO_CARTA, ALTURA_DEFECTO_CARTA)
		carta.z_index = 1
		
func raycast_check_carta_ranura():
	var space_state = get_world_2d().direct_space_state
	var parametros = PhysicsPointQueryParameters2D.new()
	parametros.position = get_global_mouse_position()
	parametros.collide_with_areas = true
	parametros.collision_mask = MASCARA_COLISION_CARTA_RANURA
	var resultado = space_state.intersect_point(parametros)
	if resultado.size() > 0:
		return resultado[0].collider.get_parent()
	return null

func raycast_check_carta():
	var space_state = get_world_2d().direct_space_state
	var parametros = PhysicsPointQueryParameters2D.new()
	parametros.position = get_global_mouse_position()
	# Detectamos áreas (cartas) sin importar su collision_mask si es posible, 
	# o simplemente usamos la máscara estándar de cartas
	parametros.collide_with_areas = true
	parametros.collision_mask = MASCARA_COLISION_CARTA
	
	var resultado = space_state.intersect_point(parametros)
	if resultado.size() > 0:
		var carta = get_carta_con_mayor_z_index(resultado)
		if carta and carta.get("is_ai"): return null
		return carta
	return null

func get_carta_con_mayor_z_index(cartas):
	var carta_mas_alta = cartas[0].collider.get_parent()
	var z_index_mas_alto = carta_mas_alta.z_index
	
	for i in range(1, cartas.size()):
		var carta_actual = cartas[i].collider.get_parent()
		if carta_actual.z_index > z_index_mas_alto:
			carta_mas_alta = carta_actual
			z_index_mas_alto = carta_actual.z_index
	
	return carta_mas_alta

func on_click_izquierdo_levantado():
	if carta_siend_arrastrada:
		dejar_de_arrastrar()

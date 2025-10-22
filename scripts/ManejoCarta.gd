extends Node2D

var carta_siend_arrastrada
var tamano_escena
const MASCARA_COLISION_CARTA = 1
const MASCARA_COLISION_CARTA_RANURA = 2
const velocidad_de_carta_default = 0.2
var cursor_sobre_carta
var mano_jugador_referencia

func _ready() -> void:
	tamano_escena = get_viewport_rect().size
	mano_jugador_referencia = $"../ManoJugador"
	$"../InputManager".connect("levantado_click_izquierdo", on_click_izquierdo_levantado)

func _process(delta: float) -> void:
	if carta_siend_arrastrada:
		var mouse_pos = get_global_mouse_position()
		carta_siend_arrastrada.global_position = Vector2(clamp(mouse_pos.x, 0, tamano_escena.x), clamp(mouse_pos.y, 0, tamano_escena.y))

func empezar_a_arrastrar(carta):
	carta_siend_arrastrada = carta
	carta.scale = Vector2(1, 1)
	
	

func dejar_de_arrastrar():
	carta_siend_arrastrada.scale = Vector2(1.05, 1.05)
	var carta_ranura_encontrada = raycast_check_carta_ranura()
	if carta_ranura_encontrada and not carta_ranura_encontrada.carta_en_ranura:
		mano_jugador_referencia.remover_carta_mano(carta_siend_arrastrada)
		carta_siend_arrastrada.global_position = carta_ranura_encontrada.global_position
		carta_siend_arrastrada.get_node("Area2D/CollisionShape2D").disabled = true
		carta_ranura_encontrada.carta_en_ranura = true
	else:
		mano_jugador_referencia.añadir_carta_mano(carta_siend_arrastrada, velocidad_de_carta_default)
	carta_siend_arrastrada = null
	
	

func connect_carta_signal(carta):
	carta.connect("sosteniendo", on_hovered_over_carta)
	carta.connect("soltando", on_hovered_off_carta)
	
func on_hovered_over_carta(carta):
	if !cursor_sobre_carta:
		cursor_sobre_carta = true 
		resaltar_carta(carta, true)

func on_hovered_off_carta(carta):
	if !carta_siend_arrastrada:
		cursor_sobre_carta = false
		resaltar_carta(carta, false)
		var nueva_carta_sosteniendo = raycast_check_carta()
		if nueva_carta_sosteniendo:
			resaltar_carta(nueva_carta_sosteniendo, true)
		else:
			cursor_sobre_carta = false

func resaltar_carta(carta, sosteniendo):
	if sosteniendo:
		carta.scale = Vector2(1.05, 1.05)
		carta.z_index = 2
	else:
		carta.scale = Vector2(1, 1)
		carta.z_index = 1
		
func raycast_check_carta_ranura():
	var space_state = get_world_2d().direct_space_state
	var parametros = PhysicsPointQueryParameters2D.new()
	parametros.position = get_global_mouse_position()
	parametros.collide_with_areas = true
	parametros.collision_mask = MASCARA_COLISION_CARTA_RANURA
	var resultado = space_state.intersect_point(parametros)
	if resultado.size() > 0:
		#return resultado[0].collider.get_parent()
			#return resultado[0].collider.get_parent()
		return resultado[0].collider.get_parent()
	
	return  null

func raycast_check_carta():
	var space_state = get_world_2d().direct_space_state
	var parametros = PhysicsPointQueryParameters2D.new()
	parametros.position = get_global_mouse_position()
	parametros.collide_with_areas = true
	parametros.collision_mask = MASCARA_COLISION_CARTA
	var resultado = space_state.intersect_point(parametros)
	if resultado.size() > 0:
		#return resultado[0].collider.get_parent()
		return get_carta_con_mayor_z_index(resultado)
	return  null

## Devuelve la carta (nodo padre del collider) con el z_index más alto.
##
## @param cartas: Array de objetos que contienen una propiedad 'collider'.
## Cada 'collider' tiene como padre un nodo con un valor de 'z_index'.
##
## @return Nodo de la carta con el z_index más alto (la que está "encima" visualmente).
func get_carta_con_mayor_z_index(cartas):
	# Tomamos la primera carta como referencia inicial
	var carta_mas_alta = cartas[0].collider.get_parent()
	var z_index_mas_alto = carta_mas_alta.z_index
	
	# Recorremos el resto de cartas para encontrar la que tiene el mayor z_index
	for i in range(1, cartas.size()):
		var carta_actual = cartas[i].collider.get_parent()
		
		# Si la carta actual tiene un z_index mayor, la marcamos como la nueva más alta
		if carta_actual.z_index > z_index_mas_alto:
			carta_mas_alta = carta_actual
			z_index_mas_alto = carta_actual.z_index
	
	# Devolvemos la carta que se encuentra más arriba visualmente
	return carta_mas_alta

func on_click_izquierdo_levantado():
	if carta_siend_arrastrada:
		dejar_de_arrastrar()

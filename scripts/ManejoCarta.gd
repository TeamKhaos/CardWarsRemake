extends Node2D

@export var manejo_jugador: Node
@export var input_manager: Node


# --- VARIABLES ---
# Referencia a la carta que se está arrastrando actualmente.
var carta_siend_arrastrada
# Tamaño de la pantalla.
var tamano_escena
# Máscara de colisión para las cartas.
const MASCARA_COLISION_CARTA = 1
# Máscara de colisión para las ranuras de las cartas.
const MASCARA_COLISION_CARTA_RANURA = 2
# Velocidad por defecto de la animación de la carta.
const velocidad_de_carta_default = 0.2
# Tamaño por defecto de la carta
const ALTURA_DEFECTO_CARTA = 0.8
const ALTURA_SUBIDA_CARTA = 0.85


# Indica si el cursor está sobre una carta.
var cursor_sobre_carta
# Referencia al nodo que gestiona la mano del jugador.
var mano_jugador_referencia

# --- FUNCIONES DE GODOT ---
# Se llama cuando el nodo entra en el árbol de la escena por primera vez.
func _ready() -> void:
	# Obtiene el tamaño de la pantalla.
	tamano_escena = get_viewport_rect().size
	# Obtiene la referencia a la mano del jugador.
	mano_jugador_referencia = manejo_jugador
	# Conecta la señal de soltar el clic izquierdo del InputManager a una función local.
	input_manager.connect("levantado_click_izquierdo", on_click_izquierdo_levantado)

# Se llama en cada fotograma.
func _process(delta: float) -> void:
	# Si se está arrastrando una carta, actualiza su posición a la del mouse.
	if carta_siend_arrastrada:
		var mouse_pos = get_global_mouse_position()
		# Limita la posición de la carta a los bordes de la pantalla.
		carta_siend_arrastrada.global_position = Vector2(clamp(mouse_pos.x, 0, tamano_escena.x), clamp(mouse_pos.y, 0, tamano_escena.y))

# --- FUNCIONES DE ARRASTRE ---
# Se llama para empezar a arrastrar una carta.
func empezar_a_arrastrar(carta):
	# Establece la carta que se está arrastrando.
	carta_siend_arrastrada = carta
	# Restaura la escala de la carta a su tamaño original.
	carta.scale = Vector2(ALTURA_DEFECTO_CARTA, ALTURA_DEFECTO_CARTA)
	
# Se llama para dejar de arrastrar una carta.
func dejar_de_arrastrar():
	# Aumenta ligeramente la escala de la carta para dar un efecto visual.
	carta_siend_arrastrada.scale = Vector2(ALTURA_SUBIDA_CARTA, ALTURA_SUBIDA_CARTA)
	# Comprueba si hay una ranura de carta debajo del cursor.
	var carta_ranura_encontrada = raycast_check_carta_ranura()
	# Si se encuentra una ranura y no está ocupada.
	if carta_ranura_encontrada and not carta_ranura_encontrada.carta_en_ranura:
		# Elimina la carta de la mano del jugador.
		mano_jugador_referencia.remover_carta_mano(carta_siend_arrastrada)
		# Coloca la carta en la posición de la ranura.
		carta_siend_arrastrada.global_position = carta_ranura_encontrada.global_position
		#se adapte al tamano
		carta_siend_arrastrada.scale = carta_ranura_encontrada.scale
		# Desactiva la colisión de la carta para que no se pueda volver a coger.
		carta_siend_arrastrada.get_node("Area2D/CollisionShape2D").disabled = true
		# Marca la ranura como ocupada.
		carta_ranura_encontrada.carta_en_ranura = true
	# Si no se encuentra una ranura válida, devuelve la carta a la mano.
	else:
		mano_jugador_referencia.añadir_carta_mano(carta_siend_arrastrada, velocidad_de_carta_default)
	# Ya no se está arrastrando ninguna carta.
	carta_siend_arrastrada = null
	
# --- MANEJO DE SEÑALES DE LA CARTA ---
# Conecta las señales de una carta a las funciones de este script.
func connect_carta_signal(carta):
	carta.connect("sosteniendo", on_hovered_over_carta)
	carta.connect("soltando", on_hovered_off_carta)
	carta.scale = Vector2(ALTURA_DEFECTO_CARTA, ALTURA_DEFECTO_CARTA)
	
# Se llama cuando el cursor pasa por encima de una carta.
func on_hovered_over_carta(carta):
	if !cursor_sobre_carta:
		cursor_sobre_carta = true 
		resaltar_carta(carta, true)

# Se llama cuando el cursor deja de estar sobre una carta.
func on_hovered_off_carta(carta):
	if !carta_siend_arrastrada:
		cursor_sobre_carta = false
		resaltar_carta(carta, false)
		# Comprueba si hay otra carta debajo del cursor para resaltarla.
		var nueva_carta_sosteniendo = raycast_check_carta()
		if nueva_carta_sosteniendo:
			resaltar_carta(nueva_carta_sosteniendo, true)
		else:
			cursor_sobre_carta = false

# --- FUNCIONES DE UTILIDAD ---
# Resalta o quita el resaltado de una carta.
func resaltar_carta(carta, sosteniendo):
	# Si se está resaltando.
	if sosteniendo:
		# Aumenta la escala y el z-index para que aparezca por encima.
		carta.scale = Vector2(ALTURA_SUBIDA_CARTA, ALTURA_SUBIDA_CARTA)
		carta.z_index = 2
	# Si se quita el resaltado.
	else:
		# Restaura la escala y el z-index.
		carta.scale = Vector2(ALTURA_DEFECTO_CARTA, ALTURA_DEFECTO_CARTA)
		carta.z_index = 1
		
# Lanza un rayo para comprobar si hay una ranura de carta debajo del cursor.
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

# Lanza un rayo para comprobar si hay una carta debajo del cursor.
func raycast_check_carta():
	
	var space_state = get_world_2d().direct_space_state
	var parametros = PhysicsPointQueryParameters2D.new()
	parametros.position = get_global_mouse_position()
	parametros.collide_with_areas = true
	parametros.collision_mask = MASCARA_COLISION_CARTA
	var resultado = space_state.intersect_point(parametros)
	if resultado.size() > 0:
		# Devuelve la carta con el z-index más alto (la que está encima).
		return get_carta_con_mayor_z_index(resultado)
	return null

# Devuelve la carta con el z_index más alto de una lista de colisiones.
func get_carta_con_mayor_z_index(cartas):
	var carta_mas_alta = cartas[0].collider.get_parent()
	var z_index_mas_alto = carta_mas_alta.z_index
	
	for i in range(1, cartas.size()):
		var carta_actual = cartas[i].collider.get_parent()
		
		if carta_actual.z_index > z_index_mas_alto:
			carta_mas_alta = carta_actual
			z_index_mas_alto = carta_actual.z_index
	
	return carta_mas_alta

# Se llama cuando se suelta el botón izquierdo del mouse.
func on_click_izquierdo_levantado():
	# Si se estaba arrastrando una carta, se deja de arrastrar.
	if carta_siend_arrastrada:
		dejar_de_arrastrar()

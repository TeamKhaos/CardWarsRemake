extends Node2D

# --- CONSTANTES ---
# Máscara de colisión para las cartas.
const MASCARA_COLISION_CARTA = 1
# Máscara de colisión para el mazo de cartas.
const MASCARA_COLISION_CARTA_DECK = 4

# --- VARIABLES ---
# Referencia al nodo que maneja las cartas.
var carta_manager_referencia
# Referencia al mazo.
var deck_referencia

# --- SEÑALES ---
# Se emite cuando se hace clic con el botón izquierdo del mouse.
signal clickeado_click_izquierdo
# Se emite cuando se suelta el botón izquierdo del mouse.
signal levantado_click_izquierdo

# --- FUNCIONES DE GODOT ---
# Se llama cuando el nodo entra en el árbol de la escena por primera vez.
func _ready() -> void:
	# Obtiene la referencia al nodo de manejo de cartas.
	carta_manager_referencia = $"../ManejoCarta"
	# Obtiene la referencia al mazo.
	deck_referencia = $"../Deck"

# Se llama cada vez que hay un evento de entrada.
func _input(event):
	# Comprueba si el evento es un clic del botón izquierdo del mouse.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Si se presiona el botón.
		if event.pressed:
			# Emite la señal de que se ha hecho clic.
			emit_signal("clickeado_click_izquierdo")
			# Lanza un rayo para detectar con qué se ha hecho clic.
			raycast_al_cursor()
		# Si se suelta el botón.
		else:
			# Emite la señal de que se ha soltado el clic.
			emit_signal("levantado_click_izquierdo")
			
# --- FUNCIONES PERSONALIZADAS ---
# Lanza un rayo desde la posición del cursor para detectar objetos.
func raycast_al_cursor():
	# Obtiene el estado del espacio 2D del mundo.
	var space_state = get_world_2d().direct_space_state
	# Crea nuevos parámetros para la consulta de puntos de física.
	var parametros = PhysicsPointQueryParameters2D.new()
	# Establece la posición de la consulta en la posición global del mouse.
	parametros.position = get_global_mouse_position()
	# Permite que la consulta colisione con áreas.
	parametros.collide_with_areas = true
	# Realiza la intersección de puntos.
	var resultado = space_state.intersect_point(parametros)
	# Si hay algún resultado.
	if resultado.size() > 0:
		# Obtiene la máscara de colisión del primer resultado.
		var resultado_collision_mask = resultado[0].collider.collision_mask
		# Si la máscara de colisión es la de una carta.
		if resultado_collision_mask == MASCARA_COLISION_CARTA:
			# Se ha seleccionado una carta.
			var carta_encontrada = resultado[0].collider.get_parent()
			# Si se encontró una carta.
			if carta_encontrada:
				# Inicia el arrastre de la carta.
				carta_manager_referencia.start_drag(carta_encontrada)
		# Si la máscara de colisión es la del mazo.
		elif resultado_collision_mask == MASCARA_COLISION_CARTA_DECK:
			# Se ha seleccionado el mazo.
			deck_referencia.tomar_carta()
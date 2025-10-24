extends Node2D
@export var manejo_carta: Node
@export var deck_: Node
# --- CONSTANTES ---
# Máscara de colisión para detectar las cartas.
const MASCARA_COLISION_CARTA = 1
# Máscara de colisión para detectar el mazo de cartas.
const MASCARA_COLISION_CARTA_DECK = 4

# --- REFERENCIAS ---
# Referencia al script que maneja la lógica de las cartas.
var carta_manager_referencia
# Referencia al script del mazo.
var deck_referencia

# --- SEÑALES ---
# Se emite cuando se hace clic con el botón izquierdo del mouse.
signal clickeado_click_izquierdo
# Se emite cuando se suelta el botón izquierdo del mouse.
signal levantado_click_izquierdo

# --- FUNCIONES DE GODOT ---
# Se llama cuando el nodo entra en el árbol de la escena por primera vez.
func _ready() -> void:
	# Obtiene las referencias a los nodos de manejo de cartas y del mazo.
	carta_manager_referencia = manejo_carta
	deck_referencia = deck_

# Se llama en cada evento de entrada (input).
func _input(event):
	# Comprueba si el evento es un clic del botón izquierdo del mouse.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Si se presiona el botón.
		if event.pressed:
			# Emite la señal de que se ha hecho clic.
			emit_signal("clickeado_click_izquierdo")
			# Lanza un rayo para detectar qué se ha clickeado.
			raycast_al_cursor()
		# Si se suelta el botón.
		else:
			# Emite la señal de que se ha soltado el clic.
			emit_signal("levantado_click_izquierdo")
			
# --- FUNCIONES DE RAYCAST ---
# Lanza un rayo desde la posición del cursor para detectar objetos.
func raycast_al_cursor():

	# Obtiene el estado del espacio 2D del mundo.
	var space_state = get_world_2d().direct_space_state
	# Crea los parámetros para la consulta de punto.
	var parametros = PhysicsPointQueryParameters2D.new()
	# Establece la posición de la consulta en la posición del mouse.
	parametros.position = get_global_mouse_position()
	# Habilita la colisión con áreas.
	parametros.collide_with_areas = true
	# Realiza la intersección de punto.
	var resultado = space_state.intersect_point(parametros)
	# Si hay algún resultado.
	if resultado.size() > 0:
		# Obtiene la máscara de colisión del objeto detectado.
		var resultado_collision_mask = resultado[0].collider.collision_mask
		# Si la máscara de colisión es la de una carta.
		if resultado_collision_mask == MASCARA_COLISION_CARTA:
			# Se ha seleccionado una carta.
			var carta_encontrada = resultado[0].collider.get_parent()
			# Si se ha encontrado una carta válida.
			if carta_encontrada:
				# Llama a la función para empezar a arrastrar la carta.
				carta_manager_referencia.empezar_a_arrastrar(carta_encontrada)
		# Si la máscara de colisión es la del mazo.
		elif resultado_collision_mask == MASCARA_COLISION_CARTA_DECK:
			# Se ha seleccionado el mazo.
			deck_referencia.tomar_carta()
			
			

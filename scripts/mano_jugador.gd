extends Node2D

# --- CONSTANTES ---
# Ancho de cada carta.
const carta_ancho = 200
# Posición en el eje Y donde se sitúa la mano.
const mano_y_posicion = 790
# Velocidad de animación por defecto para las cartas.
const velocidad_de_carta_default = 1

# --- VARIABLES ---
# Array que contiene las cartas en la mano del jugador.
var mano_jugador = []
# Posición X del centro de la pantalla.
var center_screen_x

# --- FUNCIONES DE GODOT ---
# Se llama cuando el nodo entra en el árbol de la escena por primera vez.
func _ready() -> void:
	# Calcula la posición X del centro de la pantalla.
	center_screen_x = get_viewport().size.x / 2
	
# --- FUNCIONES DE MANO ---
# Añade una carta a la mano del jugador.
func añadir_carta_mano(carta, velocidad):
	# Si la carta no está ya en la mano.
	if carta not in mano_jugador:
		# Inserta la carta al principio del array.
		mano_jugador.insert(0, carta)
		# Actualiza la posición de todas las cartas en la mano.
		actulizar_posicion_mano(velocidad)
	# Si la carta ya está en la mano, la anima para que vuelva a su posición inicial.
	else:
		animar_carta_a_posicion(carta, carta.posicion_inicial, velocidad_de_carta_default)
		
# Actualiza la posición de todas las cartas en la mano.
func actulizar_posicion_mano(velocidad):
	# Itera sobre cada carta en la mano.
	for i in range(mano_jugador.size()):
		# Calcula la nueva posición para la carta.
		var nueva_posicion = Vector2(calcular_carta_posicion(i), mano_y_posicion)
		var carta = mano_jugador[i]
		# Guarda la nueva posición como la posición inicial de la carta.
		carta.posicion_inicial = nueva_posicion
		# Anima la carta para que se mueva a su nueva posición.
		animar_carta_a_posicion(carta, nueva_posicion, velocidad) 

# Calcula la posición X de una carta en la mano basado en su índice.
func calcular_carta_posicion(index):
	# Calcula el ancho total que ocupan las cartas.
	var total_ancho = (mano_jugador.size() - 1) * carta_ancho
	# Calcula el desplazamiento en X para centrar las cartas.
	var x_offset = center_screen_x + index * carta_ancho - total_ancho / 2
	return x_offset
	
# Elimina una carta de la mano del jugador.
func remover_carta_mano(carta):
	# Si la carta está en la mano.
	if carta in mano_jugador:
		# La elimina del array.
		mano_jugador.erase(carta)
		# Actualiza la posición de las cartas restantes.
		actulizar_posicion_mano(velocidad_de_carta_default)
	
# --- FUNCIONES DE ANIMACIÓN ---
# Anima el movimiento de una carta a una nueva posición.
func animar_carta_a_posicion(carta, nueva_posicion, velocidad):
	# Crea una nueva animación (tween).
	var tween = get_tree().create_tween()
	# Anima la propiedad "position" de la carta hacia la nueva_posicion.
	tween.tween_property(carta, "position", nueva_posicion, velocidad)
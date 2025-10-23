extends Node2D

# --- CONSTANTES ---
# Ancho de cada carta para calcular su posición en la mano.
const carta_ancho = 150
# Proporción de la altura de la pantalla para la posición Y de la mano.
const mano_y_proporcion = 0.9
# Velocidad por defecto para las animaciones de las cartas.
const velocidad_de_carta_default = 0.2

# --- VARIABLES ---
# Array que almacena las cartas que el jugador tiene en la mano.
var mano_jugador = []
# --- FUNCIONES DE MANO ---
# Añade una carta a la mano del jugador.
func añadir_carta_mano(carta, velocidad):
	# Si la carta no está ya en la mano.
	if carta not in mano_jugador:
		# Inserta la carta al principio del array de la mano.
		mano_jugador.insert(0, carta)
		# Actualiza la posición de todas las cartas en la mano.
		actulizar_posicion_mano(velocidad)
	# Si la carta ya está en la mano, la devuelve a su posición inicial.
	else:
		animar_carta_a_posicion(carta, carta.posicion_inicial, velocidad_de_carta_default)
		
# Actualiza la posición de todas las cartas en la mano.
func actulizar_posicion_mano(velocidad):
	# Obtiene el tamaño actual de la ventana.
	var tamano_ventana = get_viewport().size
	# Itera sobre todas las cartas en la mano.
	for i in range(mano_jugador.size()):
		# Calcula la nueva posición de la carta.
		var nueva_posicion = Vector2(calcular_carta_posicion(i, tamano_ventana.x), tamano_ventana.y * mano_y_proporcion)
		var carta = mano_jugador[i]
		# Guarda la posición inicial de la carta.
		carta.posicion_inicial = nueva_posicion
		# Anima la carta a su nueva posición.
		animar_carta_a_posicion(carta, nueva_posicion, velocidad) 

# Calcula la posición en el eje X de una carta en la mano.
func calcular_carta_posicion(index, ancho_ventana):
	# Calcula el ancho total que ocupan las cartas.
	var total_ancho = (mano_jugador.size() - 1) * carta_ancho
	# Calcula el desplazamiento en X para centrar las cartas.
	var x_offset = ancho_ventana / 2 + index * carta_ancho - total_ancho / 2
	return x_offset
	
# Elimina una carta de la mano del jugador.
func remover_carta_mano(carta):
	# Si la carta está en la mano.
	if carta in mano_jugador:
		# Elimina la carta del array de la mano.
		mano_jugador.erase(carta)
		# Actualiza la posición de las cartas restantes.
		actulizar_posicion_mano(velocidad_de_carta_default)
	
# --- FUNCIONES DE ANIMACIÓN ---
# Anima una carta a una nueva posición.
func animar_carta_a_posicion(carta, nueva_posicion, velocidad):
	# Crea una nueva animación (tween).
	var tween = get_tree().create_tween()
	# Anima la propiedad "position" de la carta a la nueva posición.
	tween.tween_property(carta, "position", nueva_posicion, velocidad)

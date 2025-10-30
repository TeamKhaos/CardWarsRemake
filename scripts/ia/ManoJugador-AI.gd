extends Node2D

@export var deck_: Node

# --- CONSTANTES ---
const carta_ancho = 135
const velocidad_de_carta_default = 0.2

# --- VARIABLES ---
var cartas_en_mano = []
var mano_y_proporcion: float = 0.18

# --- FUNCIONES DE MANO ---
func añadir_carta_mano(carta, velocidad):
	## pendiente que las cartas salgan giradas si is player one es false
	if carta not in cartas_en_mano:
		cartas_en_mano.insert(0, carta)
		carta.name = "CartaIA"
		actulizar_posicion_mano(velocidad)
	else:
		animar_carta_a_posicion(carta, carta.posicion_inicial, velocidad_de_carta_default)

func actulizar_posicion_mano(velocidad):
	var tamano_ventana = get_viewport().size
	for i in range(cartas_en_mano.size()):
		var nueva_posicion = Vector2(calcular_carta_posicion(i, tamano_ventana.x), tamano_ventana.y * mano_y_proporcion)
		var carta = cartas_en_mano[i]
		carta.posicion_inicial = nueva_posicion
		animar_carta_a_posicion(carta, nueva_posicion, velocidad)

func calcular_carta_posicion(index, ancho_ventana):
	var total_ancho = (cartas_en_mano.size() - 1) * carta_ancho
	var x_offset = ancho_ventana / 2 + index * carta_ancho - total_ancho / 2
	return x_offset

func remover_carta_mano(carta):
	if carta in cartas_en_mano:
		cartas_en_mano.erase(carta)
		actulizar_posicion_mano(velocidad_de_carta_default)

# --- FUNCIONES DE ANIMACIÓN ---
func animar_carta_a_posicion(carta, nueva_posicion, velocidad):
	var tween = get_tree().create_tween()
	tween.tween_property(carta, "position", nueva_posicion, velocidad)

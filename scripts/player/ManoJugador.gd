
extends Node2D

@export var is_player_one: bool = true
@export var deck_: Node

# --- CONSTANTES ---
const carta_ancho = 135
const velocidad_de_carta_default = 0.2

# --- VARIABLES ---
var mano_jugador = []
var mano_y_proporcion: float

func _ready():
	if is_player_one:
		mano_y_proporcion = 0.82
	else:
		mano_y_proporcion = 0.18

# --- FUNCIONES DE MANO ---
func añadir_carta_mano(carta, velocidad):
	## pendiente que las cartas salgan giradas si is player one es false
	if carta not in mano_jugador:
		mano_jugador.insert(0, carta)
		actulizar_posicion_mano(velocidad)
	else:
		animar_carta_a_posicion(carta, carta.posicion_inicial, velocidad_de_carta_default)

func actulizar_posicion_mano(velocidad):
	var tamano_ventana = get_viewport().size
	for i in range(mano_jugador.size()):
		var nueva_posicion = Vector2(calcular_carta_posicion(i, tamano_ventana.x), tamano_ventana.y * mano_y_proporcion)
		var carta = mano_jugador[i]
		carta.posicion_inicial = nueva_posicion
		animar_carta_a_posicion(carta, nueva_posicion, velocidad)

func calcular_carta_posicion(index, ancho_ventana):
	var total_ancho = (mano_jugador.size() - 1) * carta_ancho
	var x_offset = ancho_ventana / 2 + index * carta_ancho - total_ancho / 2
	return x_offset

func remover_carta_mano(carta):
	if carta in mano_jugador:
		mano_jugador.erase(carta)
		actulizar_posicion_mano(velocidad_de_carta_default)
		
		var deck = deck_
		if deck:
			var nueva_carta = deck.reponer_carta()
			if nueva_carta:
				añadir_carta_mano(nueva_carta, velocidad_de_carta_default)

# --- FUNCIONES DE ANIMACIÓN ---
func animar_carta_a_posicion(carta, nueva_posicion, velocidad):
	var tween = get_tree().create_tween()
	tween.tween_property(carta, "position", nueva_posicion, velocidad)

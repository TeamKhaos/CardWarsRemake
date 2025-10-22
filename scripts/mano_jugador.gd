extends Node2D

const conteo_mano = 4
const carta_escena_dir = "res://scenes/card.tscn"
var mano_jugador = []
const carta_ancho = 200
const mano_y_posicion = 890
var center_screen_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x = get_viewport().size.x/2
	var carta_escena = preload(carta_escena_dir)
	for i in range(conteo_mano):
		var nueva_carta = carta_escena.instantiate()

		$"../ManejoCarta".add_child(nueva_carta)
		nueva_carta.name = "Carta"
		añadir_carta_mano(nueva_carta)

func añadir_carta_mano(carta):
	if carta not in mano_jugador:
		mano_jugador.insert(0, carta)
		actulizar_posicion_mano()
	else:
		animar_carta_a_posicion(carta, carta.posicion_inicial)
func actulizar_posicion_mano():
	for i in range(mano_jugador.size()):
		var nueva_posicion = Vector2(calcular_carta_posicion(i), mano_y_posicion)
		var carta = mano_jugador[i]
		carta.posicion_inicial = nueva_posicion
		animar_carta_a_posicion(carta, nueva_posicion) 

func calcular_carta_posicion(index):
	var total_ancho = (mano_jugador.size() - 1) * carta_ancho
	var x_offset = center_screen_x + index * carta_ancho - total_ancho / 2
	return x_offset
	
func remover_carta_mano(carta):
	if carta in mano_jugador:
		mano_jugador.erase(carta)
		actulizar_posicion_mano()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func animar_carta_a_posicion(carta, nueva_posicion):
	var tween = get_tree().create_tween()
	tween.tween_property(carta, "position", nueva_posicion, 0.1)

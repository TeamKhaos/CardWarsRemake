extends Node2D

var puntos_jugador := 0
var puntos_ia := 0
@onready var puntos_jugador_nodos = $Jugador.get_children()
@onready var puntos_ia_nodos = $IA.get_children()

func reset():
	puntos_jugador = 0
	puntos_ia = 0
	for p in puntos_jugador_nodos:
		p.modulate = Color(0.3, 0.3, 0.3)
	for p in puntos_ia_nodos:
		p.modulate = Color(0.3, 0.3, 0.3)

func sumar_punto(quien: String):
	match quien:
		"jugador":
			if puntos_jugador < puntos_jugador_nodos.size():
				puntos_jugador_nodos[puntos_jugador].modulate = Color(1, 1, 1)
				puntos_jugador += 1
		"ia":
			if puntos_ia < puntos_ia_nodos.size():
				puntos_ia_nodos[puntos_ia].modulate = Color(1, 1, 1)
				puntos_ia += 1

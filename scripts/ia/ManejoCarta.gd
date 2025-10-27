extends Node2D
var ALTURA_DEFECTO_CARTA: float
var ALTURA_SUBIDA_CARTA: float

func play_card_for_ai(carta, ranura):
	ALTURA_DEFECTO_CARTA = 1
	ALTURA_SUBIDA_CARTA = 1

	carta.global_position = ranura.global_position
	carta.scale = Vector2(ALTURA_DEFECTO_CARTA, ALTURA_DEFECTO_CARTA)
	carta.get_node("Area2D/CollisionShape2D").disabled = true
	ranura.set("carta_en_ranura", true)

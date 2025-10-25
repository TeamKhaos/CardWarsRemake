extends Node2D

func play_card_for_ai(carta, ranura):
	carta.global_position = ranura.global_position
	carta.scale = ranura.scale
	carta.get_node("Area2D/CollisionShape2D").disabled = true
	ranura.set("carta_en_ranura", true)


extends Node2D

@export var deck: Node
@export var manejo_carta: Node
@export var mano_jugador: Node
@export var slots_container: Node

func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0
	timer.one_shot = false
	timer.start()
	timer.connect("timeout", _on_timer_timeout)

func _on_timer_timeout():
	if mano_jugador.mano_jugador.size() < 5:
		deck.tomar_carta()
	else:
		play_turn()


func play_turn():
	if mano_jugador.mano_jugador.size() > 0:
		var card_to_play = mano_jugador.mano_jugador[0]
		var empty_slot = find_empty_slot()
		if empty_slot:
			manejo_carta.play_card_for_ai(card_to_play, empty_slot)
			mano_jugador.remover_carta_mano(card_to_play)

func find_empty_slot():
	for slot in slots_container.get_children():
		if not slot.get("carta_en_ranura"):
			return slot
	return null

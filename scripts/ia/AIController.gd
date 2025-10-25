extends Node2D

@export var deck: Node
@export var manejo_carta: Node
@export var mano_jugador: Node
@export var slots_container: Node

func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2
	timer.one_shot = false
	timer.start()
	timer.connect("timeout", _on_timer_timeout)

func _on_timer_timeout():
	# Si la IA tiene menos de 5 cartas, roba una
	if mano_jugador.mano_jugador.size() < 5:
		deck.tomar_carta()
	else:
		# Si ya tiene 5 cartas, juega una
		play_turn()


func play_turn():
	if mano_jugador.mano_jugador.size() > 0:
		var card_to_play = mano_jugador.mano_jugador[0]
		var empty_slot = find_empty_slot()
		
		if empty_slot:
			# Marcar la ranura como ocupada
			empty_slot.set("carta_en_ranura", true)
			mano_jugador.remover_carta_mano(card_to_play)

			# --- ANIMACIÓN ---
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)

			# Mueve la carta hacia la ranura (sin cambiar escala)
			tween.tween_property(card_to_play, "global_position", empty_slot.global_position, 0.5)

			# Cuando la animación termina, ejecuta la jugada
			tween.connect("finished", func():
				card_to_play.scale = Vector2(1, 1)
				manejo_carta.play_card_for_ai(card_to_play, empty_slot)
				manejo_carta.play_card_for_ai(card_to_play, empty_slot)
				if card_to_play.has_node("Area2D/CollisionShape2D"):
					card_to_play.get_node("Area2D/CollisionShape2D").disabled = true
			)


func find_empty_slot():
	for slot in slots_container.get_children():
		var ocupado = slot.get("carta_en_ranura")
		if not ocupado:
			return slot
	return null

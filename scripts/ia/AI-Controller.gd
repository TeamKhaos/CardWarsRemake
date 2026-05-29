extends Node2D

@export var deck: Node
@export var manejo_carta: Node
@export var slots_container: Node
@export var game_manager: Node

func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 4.0 
	timer.one_shot = false
	timer.start()
	timer.connect("timeout", _on_timer_timeout)

func _on_timer_timeout():
	# La IA juega si la ranura central está vacía
	var ranura_central = null
	for r in get_tree().get_nodes_in_group("ranuras"):
		if r.get_meta("id_ranura", "") == "ranuraia":
			ranura_central = r
			break
			
	if ranura_central and not ranura_central.get_meta("carta_en_ranura", false):
		play_turn(ranura_central)

# --- ESTRATEGIA IA ---
func choose_ai_card(player_wins: Dictionary, ai_wins: Dictionary, available_cards: Array) -> Node:
	if available_cards.size() == 0: return null

	var falta_jugador = []
	for tipo in ["fuego", "agua", "planta"]:
		if player_wins[tipo] == 0: falta_jugador.append(tipo)
		
	var peligro_jugador = ""
	for tipo in ["fuego", "agua", "planta"]:
		if player_wins[tipo] == 2: peligro_jugador = tipo
		
	var mejores_cartas = []
	var ventajas = {"fuego": "planta", "agua": "fuego", "planta": "agua"}
	
	for carta in available_cards:
		var tipo = carta.get_meta("tipo") if carta.has_meta("tipo") else "fuego"
		if peligro_jugador != "" and ventajas.has(tipo) and ventajas[tipo] == peligro_jugador:
			mejores_cartas.append(carta)
		elif tipo in falta_jugador:
			mejores_cartas.append(carta)
			
	if mejores_cartas.size() > 0:
		return mejores_cartas.pick_random()
	else:
		return available_cards.pick_random()

func play_turn(target_slot):
	# 1. Obtener cartas disponibles en sus ranuras KHAOS
	var cartas_disponibles = []
	var ranuras_khaos = []
	for r in get_tree().get_nodes_in_group("ranuras"):
		var id = r.get_meta("id_ranura", "")
		if id.begins_with("ranuraia") and id != "ranuraia":
			if r.get_meta("carta_en_ranura", false):
				var carta = r.get_meta("carta_en_ranura_node", null)
				if is_instance_valid(carta):
					cartas_disponibles.append(carta)
					ranuras_khaos.append(r)
	
	if cartas_disponibles.size() > 0:
		var player_wins = {"fuego": game_manager.puntos_jugador.indice_fuego, "agua": game_manager.puntos_jugador.indice_agua, "planta": game_manager.puntos_jugador.indice_planta}
		var ai_wins = {"fuego": game_manager.puntos_ia.indice_fuego, "agua": game_manager.puntos_ia.indice_agua, "planta": game_manager.puntos_ia.indice_planta}
		
		var card_to_play = choose_ai_card(player_wins, ai_wins, cartas_disponibles)
		
		# Encontrar de qué ranura viene para liberarla
		var slot_origen = null
		for i in range(cartas_disponibles.size()):
			if cartas_disponibles[i] == card_to_play:
				slot_origen = ranuras_khaos[i]
				break
		
		if card_to_play and target_slot and slot_origen:
			# Liberar origen
			slot_origen.set_meta("carta_en_ranura", false)
			slot_origen.set_meta("carta_en_ranura_node", null)
			
			# Ocupar destino
			target_slot.set_meta("carta_en_ranura", true)
			target_slot.set_meta("carta_en_ranura_node", card_to_play)
			
			game_manager.registrar_carta(target_slot.get_meta("id_ranura", ""), card_to_play, true)
			
			# Animación
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(card_to_play, "global_position", target_slot.global_position, 0.5)
			# Mantener escala 0.8 para que parezca 'flotando' hacia el centro
			tween.parallel().tween_property(card_to_play, "scale", Vector2(0.8, 0.8), 0.5)
			
			# Reponer la ranura KHAOS que quedó vacía
			deck.reponer_carta_en_ranura(slot_origen)

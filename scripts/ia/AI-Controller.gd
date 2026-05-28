extends Node2D

@export var deck: Node
@export var manejo_carta: Node
@export var mano_ia: Node
@export var slots_container: Node
@export var game_manager: Node

func _ready():
	# El timer debe ser más lento y más controlado
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 4.0 # Aumentamos tiempo entre decisiones
	timer.one_shot = false
	timer.start()
	timer.connect("timeout", _on_timer_timeout)

func _on_timer_timeout():
	# Primero, intentar jugar si hay slots vacíos
	if find_empty_slot():
		play_turn()
	# Solo robar si la mano está vacía o muy baja, y no durante el reparto inicial
	elif mano_ia.cartas_en_mano.size() < 2:
		deck.tomar_carta()

func reponer_carta():
	if mano_ia.cartas_en_mano.size() < 5:
		deck.tomar_carta()

# --- ESTRATEGIA IA ---
func choose_ai_card(player_wins: Dictionary, ai_wins: Dictionary, ai_hand: Array) -> Node:
	# 1. Identificar elemento que le falta al jugador para ganar por 1 de cada
	var falta_jugador = []
	for tipo in ["fuego", "agua", "planta"]:
		if player_wins[tipo] == 0: falta_jugador.append(tipo)
		
	# 2. Identificar si al jugador le falta poco para 3 iguales
	var peligro_jugador = ""
	for tipo in ["fuego", "agua", "planta"]:
		if player_wins[tipo] == 2: peligro_jugador = tipo
		
	# 3. Elegir carta
	var mejores_cartas = []
	var ventajas = {"fuego": "planta", "agua": "fuego", "planta": "agua"}
	
	for carta in ai_hand:
		var tipo = carta.get_meta("tipo")
		
		# Prioridad: Bloquear al jugador si está a punto de ganar
		if peligro_jugador != "" and ventajas[tipo] == peligro_jugador:
			mejores_cartas.append(carta)
		elif tipo in falta_jugador:
			mejores_cartas.append(carta)
			
	if mejores_cartas.size() > 0:
		return mejores_cartas.pick_random()
	else:
		return ai_hand.pick_random()

func play_turn():
	if mano_ia.cartas_en_mano.size() > 0:
		var player_wins = {"fuego": game_manager.puntos_jugador.indice_fuego, "agua": game_manager.puntos_jugador.indice_agua, "planta": game_manager.puntos_jugador.indice_planta}
		var ai_wins = {"fuego": game_manager.puntos_ia.indice_fuego, "agua": game_manager.puntos_ia.indice_agua, "planta": game_manager.puntos_ia.indice_planta}
		
		var card_to_play = choose_ai_card(player_wins, ai_wins, mano_ia.cartas_en_mano)
		var empty_slot = find_empty_slot()
		
		if empty_slot:
			# Marcar la ranura como ocupada usando metadata
			empty_slot.set_meta("carta_en_ranura", true)
			game_manager.registrar_carta(empty_slot.get_meta("id_ranura", ""), card_to_play, true)
			mano_ia.remover_carta_mano(card_to_play)
			reponer_carta()
			
			# --- ANIMACIÓN ---
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(card_to_play, "global_position", empty_slot.global_position, 0.5)
			tween.parallel().tween_property(card_to_play, "scale", Vector2(0.7, 0.7), 0.5) # Ajuste a 0.7 para coincidir

			tween.connect("finished", func():
				# Aseguramos escala final 0.7
				card_to_play.scale = Vector2(0.7, 0.7)
				if card_to_play.has_node("Area2D/CollisionShape2D"):
					card_to_play.get_node("Area2D/CollisionShape2D").disabled = true
			)
			


		
func find_empty_slot():
	var ranuras = get_tree().get_nodes_in_group("ranuras")
	for ranura in ranuras:
		var id = ranura.get_meta("id_ranura", "")
		if id.begins_with("ranuraia"):
			if not ranura.get_meta("carta_en_ranura", false):
				return ranura
	return null

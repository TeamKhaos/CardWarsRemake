extends Node

# --- Nodo central del juego (coordina jugador, IA y combate) ---
@onready var combate = preload("res://scripts/ia/combate.gd").new()
@onready var puntos_ia = $"../BarajaIA/puntos"
@onready var puntos_jugador = $"../baraja_player/puntos"

signal ronda_resultado(resultado: String)
signal partida_terminada(ganador: String)

const RESULTADO_FINAL = preload("uid://dimdttbrr0rdu")


var cartas_en_ranuras := {}  # {"ranuraplayer": {"jugador": null, "ia": null}}

func _ready():
	add_child(combate)
	combate.resetear_puntajes()
	print("✅ Game_Manager listo.")

func registrar_carta(ranura_id: String, carta: Node, es_ia: bool):

	var ranura_combate_id = ranura_id.replace("player", "").replace("ia", "")
	if not cartas_en_ranuras.has(ranura_combate_id):
		cartas_en_ranuras[ranura_combate_id] = {"jugador": null, "ia": null}
	if es_ia:
		cartas_en_ranuras[ranura_combate_id]["ia"] = carta 
	else:
		cartas_en_ranuras[ranura_combate_id]["jugador"] = carta 

	var ataque = carta.get_meta("ataque")
	var tipo = carta.get_meta("tipo")
	print("game manager Carta cayó en", ranura_id, ":", carta.name, "→ { ataque:", ataque, ", tipo:", tipo, " }")


	if cartas_en_ranuras[ranura_combate_id]["jugador"] and cartas_en_ranuras[ranura_combate_id]["ia"]:
		comparar_cartas(ranura_combate_id)

func comparar_cartas(ranura_id: String):
	var carta_jugador = cartas_en_ranuras[ranura_id]["jugador"]
	var carta_ia = cartas_en_ranuras[ranura_id]["ia"]

	if not carta_jugador or not carta_ia:
		return

	var resultado = combate.determinar_resultado(carta_jugador, carta_ia)
	print("⚔️ Resultado en", ranura_id, "→", resultado)

	var ganador_global = combate.registrar_resultado(carta_jugador, carta_ia)

	match resultado:
		"jugador":
			print("🏆 Jugador gana en", ranura_id)
			await get_tree().create_timer(2.0).timeout
			var tipo = carta_jugador.get_meta("tipo")
			puntos_jugador.agregar_punto(tipo)
			carta_jugador.get_node("Cardimage").modulate = Color(1, 1, 1, 1)
			carta_ia.get_node("Cardimage").modulate = Color(0.5, 0.5, 0.5, 1)
			if verificar_victoria_final("Jugador"):
				return 

		"ia":
			print("🤖 IA gana en", ranura_id)
			await get_tree().create_timer(2.0).timeout
			var tipo = carta_ia.get_meta("tipo")
			puntos_ia.agregar_punto(tipo)
			carta_ia.get_node("Cardimage").modulate = Color(1, 1, 1, 1)
			carta_jugador.get_node("Cardimage").modulate = Color(0.5, 0.5, 0.5, 1)
			if verificar_victoria_final("IA"):
				return
		"empate":
			print("⚖️ Empate en", ranura_id)
			await get_tree().create_timer(1.0).timeout
			carta_ia.get_node("Cardimage").modulate = Color(0.5, 0.5, 0.5, 1)
			carta_jugador.get_node("Cardimage").modulate = Color(0.5, 0.5, 0.5, 1)

	await get_tree().create_timer(1.0).timeout

	if is_instance_valid(carta_jugador):
		print("Carta eliminada", carta_jugador)
		$"../CartaRanura".set("carta_en_ranura", false)
		carta_jugador.queue_free()
	if is_instance_valid(carta_ia):
		print("Carta eliminada", carta_jugador)
		$"../CartaRanura2".set("carta_en_ranura", false)
		carta_ia.queue_free()

	print("🗑️ Limpiando ranura ", ranura_id)
	cartas_en_ranuras[ranura_id]["jugador"] = null
	cartas_en_ranuras[ranura_id]["ia"] = null

	if ganador_global != "":
		print("🎉 ¡Victoria final para:", ganador_global, "!")
		mostrar_pantalla_final(ganador_global)
		combate.resetear_puntajes()

func verificar_victoria_final(jugador_o_ia: String) -> bool:
	var nodo_puntos = puntos_jugador if jugador_o_ia == "Jugador" else puntos_ia
	
	# Asumimos que los puntos son contados por los índices del script de puntos
	# (indice_fuego, indice_agua, indice_planta)
	var f = nodo_puntos.indice_fuego
	var a = nodo_puntos.indice_agua
	var p = nodo_puntos.indice_planta
	
	# --- Condición 1: 3 puntos de un mismo elemento ---
	var gano_por_tres_iguales = (f == 3) or (a == 3) or (p == 3)
	
	# --- Condición 2: 1 punto de cada elemento (3 puntos en total) ---
	var gano_por_uno_de_cada_uno = (f >= 1) and (a >= 1) and (p >= 1)
	
	if gano_por_tres_iguales or gano_por_uno_de_cada_uno:
		print("🎉 ¡Victoria final para:", jugador_o_ia, "!")
		mostrar_pantalla_final(jugador_o_ia) 
		
		combate.resetear_puntajes()
		return true
	return false


# Agrega esta nueva función al final de game_manager.gd
func mostrar_pantalla_final(ganador_o_empate: String):
	var pantalla_resultado = RESULTADO_FINAL.instantiate()

	pantalla_resultado.mostrar_resultado(ganador_o_empate) 
	get_tree().get_root().add_child(pantalla_resultado)

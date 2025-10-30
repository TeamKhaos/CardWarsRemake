extends Node
# --- Nodo central del juego (coordina jugador, IA y combate) ---

@onready var combate = preload("res://scripts/ia/combate.gd").new()


signal ronda_resultado(resultado: String)
signal partida_terminada(ganador: String)

func _ready():
	add_child(combate)
	combate.resetear_puntajes()
	
	print("✅ Game_Manager listo.")


var cartas_en_ranuras := {}  # {"ranura1": {"jugador": null, "ia": null}}

func registrar_carta(ranura_id: String, carta: Node, es_ia: bool):
	if not cartas_en_ranuras.has(ranura_id):
		cartas_en_ranuras[ranura_id] = {"jugador": null, "ia": null}
	
	if es_ia:
		cartas_en_ranuras[ranura_id]["ia"] = carta
	else:
		cartas_en_ranuras[ranura_id]["jugador"] = carta

	var ataque = carta.get_meta("ataque")
	var tipo = carta.get_meta("tipo")
	print("📥 Carta cayó en", ranura_id, ":", carta.name, "→ { ataque:", ataque, ", tipo:", tipo, " }")

func comparar_cartas():
	for ranura_id in cartas_en_ranuras.keys():
		var carta_jugador = cartas_en_ranuras[ranura_id]["jugador"]
		var carta_ia = cartas_en_ranuras[ranura_id]["ia"]

		if carta_jugador and carta_ia:
			var ataque_jugador = carta_jugador.get_meta("ataque")
			var tipo_jugador = carta_jugador.get_meta("tipo")
			var ataque_ia = carta_ia.get_meta("ataque")
			var tipo_ia = carta_ia.get_meta("tipo")

			var resultado = calcular_resultado(ataque_jugador, tipo_jugador, ataque_ia, tipo_ia)

			match resultado:
				"jugador":
					print("🏆 Jugador gana en", ranura_id)
				"ia":
					print("🤖 IA gana en", ranura_id)
				"empate":
					print("⚖️ Empate en", ranura_id)

func calcular_resultado(ataque_jugador, tipo_jugador, ataque_ia, tipo_ia) -> String:
	var ventajas = {
		"agua": "fuego",
		"fuego": "planta",
		"planta": "agua"
	}
	
	if tipo_jugador == tipo_ia:
		if ataque_jugador > ataque_ia:
			return "jugador"
		elif ataque_ia > ataque_jugador:
			return "ia"
		else:
			return "empate"
	elif ventajas[tipo_jugador] == tipo_ia:
		return "jugador"
	else:
		return "ia"

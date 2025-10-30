extends Node

# --- Nodo central del juego (coordina jugador, IA y combate) ---
@onready var combate = preload("res://scripts/ia/combate.gd").new()

signal ronda_resultado(resultado: String)
signal partida_terminada(ganador: String)

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
		"ia":
			print("🤖 IA gana en", ranura_id)
		"empate":
			print("⚖️ Empate en", ranura_id)

	await get_tree().create_timer(5.0).timeout

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
		emit_signal("partida_terminada", ganador_global)
		combate.resetear_puntajes()

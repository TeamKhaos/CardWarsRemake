extends Node

@onready var combate = preload("res://scripts/ia/combate.gd").new()
@onready var puntos_ia = $"../BarajaIA/puntos"
@onready var puntos_jugador = $"../baraja_player/puntos"

signal ronda_resultado(resultado: String)
signal partida_terminada(ganador: String)


const RESULTADO_FINAL = preload("uid://dimdttbrr0rdu") 


var cartas_en_ranuras := {}
var turn_timer: Timer

func _ready():
	add_child(combate)
	combate.resetear_puntajes()

	# Inicializar temporizador de 30 segundos
	turn_timer = Timer.new()
	turn_timer.wait_time = 30.0
	turn_timer.one_shot = true
	turn_timer.connect("timeout", Callable(self, "_on_TurnTimer_timeout"))
	add_child(turn_timer)

	print("✅ Game_Manager listo.")

func iniciar_turno_jugador():
	turn_timer.start()
	print("⏱️ Turno iniciado. 30 segundos restantes.")

func detener_turno():
	turn_timer.stop()

# --- MODIFICADO: comparar_cartas ahora detiene el timer ---
func registrar_carta(ranura_id: String, carta: Node, es_ia: bool):

	var ranura_combate_id = ranura_id.replace("player", "").replace("ia", "")
	if not cartas_en_ranuras.has(ranura_combate_id):
		cartas_en_ranuras[ranura_combate_id] = {"jugador": null, "ia": null}
	if es_ia:
		cartas_en_ranuras[ranura_combate_id]["ia"] = carta
		print("game manager IA registró una carta en", ranura_id)
	else:
		cartas_en_ranuras[ranura_combate_id]["jugador"] = carta
		var ataque = carta.get_meta("ataque")
		var tipo = carta.get_meta("tipo")
		print("game manager Jugador cayó en", ranura_id, ":", carta.name, "→ { ataque:", ataque, ", tipo:", tipo, " }")

	if cartas_en_ranuras[ranura_combate_id]["jugador"] and cartas_en_ranuras[ranura_combate_id]["ia"]:
		comparar_cartas(ranura_combate_id)

func comparar_cartas(ranura_id: String):
	detener_turno() # Detener timer al resolver combate

	var carta_jugador = cartas_en_ranuras[ranura_id]["jugador"]
	var carta_ia = cartas_en_ranuras[ranura_id]["ia"]

	# --- REVELADO SIMULTÁNEO ---
	print("⚔️ Revelando cartas en", ranura_id)
	if carta_ia.has_method("flip_face_up"):
		carta_ia.flip_face_up()
	
	# Pausa para dar efecto de revelado
	await get_tree().create_timer(1.0).timeout 

	var resultado = combate.determinar_resultado(carta_jugador, carta_ia)
	print("⚔️ Resultado en", ranura_id, "→", resultado)

	var ganador_global = combate.registrar_resultado(carta_jugador, carta_ia)

	match resultado:
		"jugador":
			print("🏆 Jugador gana en", ranura_id)
			await get_tree().create_timer(1.0).timeout
			var tipo = carta_jugador.get_meta("tipo")
			puntos_jugador.agregar_punto(tipo)
			carta_jugador.get_node("Cardimage").modulate = Color(1, 1, 1, 1)
			carta_ia.get_node("Cardimage").modulate = Color(0.5, 0.5, 0.5, 1)
			if verificar_victoria_final("Jugador"):
				return

		"ia":
			print("🤖 IA gana en", ranura_id)
			await get_tree().create_timer(1.0).timeout
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
		print("Carta eliminada", carta_ia)
		$"../CartaRanura2".set("carta_en_ranura", false)
		carta_ia.queue_free()

	print("🗑️ Limpiando ranura ", ranura_id)
	cartas_en_ranuras[ranura_id]["jugador"] = null
	cartas_en_ranuras[ranura_id]["ia"] = null

	if ganador_global != "":
		print("🎉 ¡Victoria final para:", ganador_global, "!")
		mostrar_pantalla_final(ganador_global)
		combate.resetear_puntajes()

# --- TEMPORIZADOR DE TURNO (A LLAMAR DESDE UN NODO TIMER) ---
func _on_TurnTimer_timeout():
	print("⏱️ Tiempo agotado. Forzando movimiento del jugador...")
	
	# 1. Obtener acceso a la mano y ranuras
	var mano_jugador = get_tree().root.find_child("ManoJugador", true, false)
	var ranura_jugador = get_tree().root.find_child("CartaRanura", true, false) # Ajustar según tu jerarquía
	
	if mano_jugador and ranura_jugador and not ranura_jugador.carta_en_ranura:
		var cartas = mano_jugador.mano_jugador
		if cartas.size() > 0:
			var carta_azar = cartas.pick_random()
			
			# 2. Mover carta a la ranura
			carta_azar.global_position = ranura_jugador.global_position
			carta_azar.get_node("Area2D/CollisionShape2D").disabled = true
			ranura_jugador.carta_en_ranura = true
			
			# 3. Remover de la mano y registrar en GameManager
			mano_jugador.remover_carta_mano(carta_azar)
			registrar_carta(ranura_jugador.id_ranura, carta_azar, false)
			print("⏱️ Carta forzada jugada:", carta_azar.name)



func verificar_victoria_final(jugador_o_ia: String) -> bool:
	var nodo_puntos = puntos_jugador if jugador_o_ia == "Jugador" else puntos_ia
	
	var f = nodo_puntos.indice_fuego
	var a = nodo_puntos.indice_agua
	var p = nodo_puntos.indice_planta
	
	var gano_por_tres_iguales = (f == 3) or (a == 3) or (p == 3)
	
	var gano_por_uno_de_cada_uno = (f >= 1) and (a >= 1) and (p >= 1)
	
	if gano_por_tres_iguales or gano_por_uno_de_cada_uno:
		print("🎉 ¡Victoria final para:", jugador_o_ia, "!")
		mostrar_pantalla_final(jugador_o_ia)
		combate.resetear_puntajes()
		return true
	return false


func restablecer_modulacion_cartas():
	var contenedor_jugador = $"../baraja_player"
	var contenedor_ia = $"../BarajaIA"
	for carta in contenedor_jugador.get_children():
		if is_instance_valid(carta) and carta.has_node("Cardimage"):
			carta.get_node("Cardimage").modulate = Color(1, 1, 1, 1)
	for carta in contenedor_ia.get_children():
		if is_instance_valid(carta) and carta.has_node("Cardimage"):
			carta.get_node("Cardimage").modulate = Color(1, 1, 1, 1)

func mostrar_pantalla_final(ganador_o_empate: String):
	restablecer_modulacion_cartas()
	var pantalla_resultado = RESULTADO_FINAL.instantiate()
	var overlay = get_tree().get_root().get_node("Demo/CanvasLayer")
	overlay.add_child(pantalla_resultado)
	pantalla_resultado.mostrar_resultado(ganador_o_empate)

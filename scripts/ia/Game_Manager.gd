extends Node

@onready var combate = preload("res://scripts/ia/combate.gd").new()
@onready var puntos_ia = $"../BarajaIA/puntos"
@onready var puntos_jugador = $"../baraja_player/puntos"

signal ronda_resultado(resultado: String)
signal partida_terminada(ganador: String)


const RESULTADO_FINAL = preload("uid://dimdttbrr0rdu") 


var cartas_en_ranuras := {}
var turn_timer: Timer
var combate_en_curso: bool = false
var reparte_ia_terminado: bool = false
var reparte_jugador_terminado: bool = false

func _ready():
	add_to_group("game_manager")
	add_child(combate)
	combate.resetear_puntajes()

	# Inicializar temporizador de 20 segundos
	turn_timer = Timer.new()
	turn_timer.wait_time = 20.0
	turn_timer.one_shot = true
	turn_timer.connect("timeout", Callable(self, "_on_TurnTimer_timeout"))
	add_child(turn_timer)

	print("✅ Game_Manager listo.")

# --- Nuevo método para sincronizar el reparto ---
func senal_reparto_terminado(es_ia: bool):
	if es_ia: reparte_ia_terminado = true
	else: reparte_jugador_terminado = true
	
	if reparte_ia_terminado and reparte_jugador_terminado:
		print("⚔️ [GM] Todos los carriles llenos. Iniciando combate.")
		iniciar_turno_jugador()

func iniciar_turno_jugador():
	if combate_en_curso: return
	combate_en_curso = true
	turn_timer.start()
	print("⏱️ Turno iniciado.")

func detener_turno():
	turn_timer.stop()

# --- MODIFICADO: COMPARAR CARTAS DINÁMICAMENTE ---
func registrar_carta(ranura_id: String, carta: Node, es_ia: bool):
	# Extraer la letra identificadora (k, h, a, o, s) de forma más robusta
	var carril_id = ""
	var id_lower = ranura_id.to_lower()
	
	for letra in ["k", "h", "a", "o", "s"]:
		if id_lower.ends_with(letra):
			carril_id = letra
			break
	
	if carril_id == "": carril_id = ranura_id # Fallback
	
	if not cartas_en_ranuras.has(carril_id):
		cartas_en_ranuras[carril_id] = {
			"jugador": null, 
			"ia": null,
			"nodo_player": null,
			"nodo_ia": null
		}
	
	# Buscar el nodo de la ranura para guardarlo
	var nodo_ranura = null
	for r in get_tree().get_nodes_in_group("ranuras"):
		if r.get_meta("id_ranura", "") == ranura_id:
			nodo_ranura = r
			break

	if es_ia:
		cartas_en_ranuras[carril_id]["ia"] = carta
		cartas_en_ranuras[carril_id]["nodo_ia"] = nodo_ranura
		print("✅ [GM] IA registró carta en carril:", carril_id)
	else:
		cartas_en_ranuras[carril_id]["jugador"] = carta
		cartas_en_ranuras[carril_id]["nodo_player"] = nodo_ranura
		print("✅ [GM] Jugador registró carta en carril:", carril_id)

func comparar_cartas(ranura_id: String):
	var carta_jugador = cartas_en_ranuras[ranura_id]["jugador"]
	var carta_ia = cartas_en_ranuras[ranura_id]["ia"]
	var nodo_ranura_p = cartas_en_ranuras[ranura_id]["nodo_player"]
	var nodo_ranura_ia = cartas_en_ranuras[ranura_id]["nodo_ia"]

	# --- REVELADO SIMULTÁNEO ---
	print("⚔️ Revelando cartas en carril:", ranura_id)
	if carta_ia.has_method("flip_face_up"):
		carta_ia.flip_face_up()
	
	if carta_ia.has_method("revelar_color_elemental"):
		carta_ia.revelar_color_elemental(carta_ia.get_meta("tipo"))
	
	await get_tree().create_timer(1.0).timeout 

	var resultado = combate.determinar_resultado(carta_jugador, carta_ia)
	var ganador_global = combate.registrar_resultado(carta_jugador, carta_ia)

	match resultado:
		"jugador":
			puntos_jugador.agregar_punto(carta_jugador.get_meta("tipo"))
			carta_jugador.get_node("Cardimage").modulate = Color(1, 1, 1, 1)
			carta_ia.get_node("Cardimage").modulate = Color(0.5, 0.5, 0.5, 1)
			if verificar_victoria_final("Jugador"): return
		"ia":
			puntos_ia.agregar_punto(carta_ia.get_meta("tipo"))
			carta_ia.get_node("Cardimage").modulate = Color(1, 1, 1, 1)
			carta_jugador.get_node("Cardimage").modulate = Color(0.5, 0.5, 0.5, 1)
			if verificar_victoria_final("IA"): return
		"empate":
			carta_ia.get_node("Cardimage").modulate = Color(0.5, 0.5, 0.5, 1)
			carta_jugador.get_node("Cardimage").modulate = Color(0.5, 0.5, 0.5, 1)

	await get_tree().create_timer(1.0).timeout

	# LIMPIAR DINÁMICAMENTE
	if is_instance_valid(carta_jugador):
		if nodo_ranura_p: nodo_ranura_p.set_meta("carta_en_ranura", false)
		carta_jugador.queue_free()
	if is_instance_valid(carta_ia):
		if nodo_ranura_ia: nodo_ranura_ia.set_meta("carta_en_ranura", false)
		carta_ia.queue_free()

	cartas_en_ranuras[ranura_id]["jugador"] = null
	cartas_en_ranuras[ranura_id]["ia"] = null
	cartas_en_ranuras[ranura_id]["nodo_player"] = null
	cartas_en_ranuras[ranura_id]["nodo_ia"] = null

	if ganador_global != "":
		mostrar_pantalla_final(ganador_global)
		combate.resetear_puntajes()
		detener_turno()

func _on_TurnTimer_timeout():
	print("⏱️ Tiempo agotado. Iniciando combate total...")
	iniciar_combate_total()

func iniciar_combate_total():
	detener_turno()
	combate_en_curso = true
	
	# Resolver todos los carriles que tengan carta
	for ranura_id in cartas_en_ranuras.keys():
		if cartas_en_ranuras[ranura_id]["jugador"] and cartas_en_ranuras[ranura_id]["ia"]:
			await comparar_cartas(ranura_id)
			
	combate_en_curso = false
	print("⚔️ Combate finalizado. Esperando jugador para próximo turno...")

func verificar_victoria_final(jugador_o_ia: String) -> bool:
	var nodo_puntos = puntos_jugador if jugador_o_ia == "Jugador" else puntos_ia
	var f = nodo_puntos.indice_fuego
	var a = nodo_puntos.indice_agua
	var p = nodo_puntos.indice_planta
	if (f == 3) or (a == 3) or (p == 3) or ((f >= 1) and (a >= 1) and (p >= 1)):
		mostrar_pantalla_final(jugador_o_ia)
		combate.resetear_puntajes()
		return true
	return false

func restablecer_modulacion_cartas():
	for c in get_tree().get_nodes_in_group("cartas"):
		if is_instance_valid(c) and c.has_node("Cardimage"):
			c.get_node("Cardimage").modulate = Color(1, 1, 1, 1)

func mostrar_pantalla_final(ganador_o_empate: String):
	restablecer_modulacion_cartas()
	var pantalla_resultado = RESULTADO_FINAL.instantiate()
	var overlay = get_tree().get_root().get_node("Demo/CanvasLayer")
	overlay.add_child(pantalla_resultado)
	pantalla_resultado.mostrar_resultado(ganador_o_empate)

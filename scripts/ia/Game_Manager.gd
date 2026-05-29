extends Node

@onready var combate = preload("res://scripts/ia/combate.gd").new()

signal ronda_resultado(resultado: String)
signal partida_terminada(ganador: String)

const RESULTADO_FINAL = preload("uid://dimdttbrr0rdu") 

var puntos_ia
var puntos_jugador
var cartas_en_ranuras := {}
var turn_timer: Timer
var combate_en_curso: bool = false
var reparte_ia_terminado: bool = false
var reparte_jugador_terminado: bool = false

func _ready():
	add_to_group("game_manager")
	add_child(combate)
	combate.resetear_puntajes()

	# Inicializar temporizador de 22 segundos (un poco más que los 21 frames del visual)
	turn_timer = Timer.new()
	turn_timer.wait_time = 22.0
	turn_timer.one_shot = true
	turn_timer.connect("timeout", Callable(self, "_on_TurnTimer_timeout"))
	add_child(turn_timer)

	# Inicializar referencias de forma segura tras el frame inicial
	await get_tree().process_frame
	puntos_ia = get_node_or_null("../BarajaIA/puntos")
	puntos_jugador = get_node_or_null("../baraja_player/puntos")
	
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
	
	# Reiniciar el temporizador visual si existe
	var temporizador = get_tree().root.find_child("Temporizador", true, false)
	if temporizador:
		temporizador.detener_temporizador()
		temporizador.iniciar_cuenta_regresiva()
		
	print("⏱️ Turno iniciado.")

func detener_turno():
	turn_timer.stop()
	# Detener temporizador visual
	var temporizador = get_tree().root.find_child("Temporizador", true, false)
	if temporizador:
		temporizador.detener_temporizador()

# --- MODIFICADO: COMPARAR CARTAS DINÁMICAMENTE ---
func registrar_carta(ranura_id: String, carta: Node, es_ia: bool):
	# Permitir ranuras de combate genéricas y todas las ranuras del jugador/IA (KHAOS)
	var es_ranura_valida = (
		ranura_id == "ranuraplayer" or ranura_id == "ranuraia" or
		ranura_id.begins_with("ranuraplayer") or ranura_id.begins_with("ranuraia")
	)
	
	if not es_ranura_valida:
		print("⚠️ [GM] Ignorando registro en ranura no de combate: ", ranura_id)
		return
	
	if not cartas_en_ranuras.has(ranura_id):
		cartas_en_ranuras[ranura_id] = {
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
		# --- PROTECCIÓN: NO SOBREESCRIBIR SI YA HAY CARTA ---
		if cartas_en_ranuras[ranura_id]["ia"] != null:
			print("⚠️ [GM] Intentando registrar IA en ranura ocupada. Ignorando.")
			return
		
		cartas_en_ranuras[ranura_id]["ia"] = carta
		cartas_en_ranuras[ranura_id]["nodo_ia"] = nodo_ranura
		print("✅ [GM] IA registró carta en ranura de combate:", ranura_id)
	else:
		# --- PROTECCIÓN: NO SOBREESCRIBIR SI YA HAY CARTA ---
		if cartas_en_ranuras[ranura_id]["jugador"] != null:
			print("⚠️ [GM] Intentando registrar Jugador en ranura ocupada. Ignorando.")
			return
			
		cartas_en_ranuras[ranura_id]["jugador"] = carta
		cartas_en_ranuras[ranura_id]["nodo_player"] = nodo_ranura
		print("✅ [GM] Jugador registró carta en ranura de combate:", ranura_id)

	# --- DISPARAR COMBATE AUTOMÁTICO SI ES CARRIL CENTRAL ---
	if ranura_id == "ranuraplayer" or ranura_id == "ranuraia":
		# UNIFICAR CLAVE: Siempre usamos "ranuraplayer" para el estado del combate central
		var clave_combate = "ranuraplayer"
		
		# Asegurar que la estructura exista
		if not cartas_en_ranuras.has(clave_combate):
			cartas_en_ranuras[clave_combate] = {"jugador": null, "ia": null, "nodo_player": null, "nodo_ia": null}
		
		# Transferir si es necesario
		if ranura_id == "ranuraia" and es_ia:
			cartas_en_ranuras[clave_combate]["ia"] = carta
			cartas_en_ranuras[clave_combate]["nodo_ia"] = nodo_ranura
		elif ranura_id == "ranuraplayer" and not es_ia:
			cartas_en_ranuras[clave_combate]["jugador"] = carta
			cartas_en_ranuras[clave_combate]["nodo_player"] = nodo_ranura
			
		# Comprobar seguridad: ¿existen ambas partes?
		var p_ok = cartas_en_ranuras[clave_combate]["jugador"] != null
		var ia_ok = cartas_en_ranuras[clave_combate]["ia"] != null
		
		if p_ok and ia_ok:
			await comparar_cartas_centrales()

var ia_esperando: bool = false # Añadir como variable de clase si no existe

func comparar_cartas_centrales():
	if ia_esperando: return # Evitar bucle
	ia_esperando = true
	
	# Comparar específicamente el carril central (unificado en "ranuraplayer")
	await comparar_cartas("ranuraplayer")
	
	# Ya no instanciamos cartas aquí. 
	# El AI-Controller detectará que 'ranuraia' está vacía y jugará una carta en su próximo tick.
	print("🤖 [GM] Carril central resuelto. Esperando siguiente jugada de la IA...")
	
	ia_esperando = false


# --- FUNCIONES AUXILIARES DE SEGURIDAD ---
func set_card_modulate(carta: Node, color: Color):
	if is_instance_valid(carta) and carta.has_node("Cardimage"):
		carta.get_node("Cardimage").modulate = color

func comparar_cartas(ranura_id: String):
	# PROTECCIÓN CONTRA RE-ENTRADA (Doble puntaje)
	if not cartas_en_ranuras.has(ranura_id): return
	if cartas_en_ranuras[ranura_id].get("resolviendo", false): return
	
	# COMPROBACIÓN CRÍTICA
	if cartas_en_ranuras[ranura_id]["jugador"] == null or cartas_en_ranuras[ranura_id]["ia"] == null:
		return
	
	# Marcar como en resolución para evitar que el timer u otro registro lo llame
	cartas_en_ranuras[ranura_id]["resolviendo"] = true
	detener_turno() # Detener timer lógico inmediatamente
	
	var carta_jugador = cartas_en_ranuras[ranura_id]["jugador"]
	var carta_ia = cartas_en_ranuras[ranura_id]["ia"]
	var nodo_ranura_p = cartas_en_ranuras[ranura_id]["nodo_player"]
	var nodo_ranura_ia = cartas_en_ranuras[ranura_id]["nodo_ia"]


	# --- REVELADO SIMULTÁNEO ---
	print("⚔️ Revelando cartas en carril:", ranura_id)
	
	if is_instance_valid(carta_ia):
		var anim = carta_ia.get_node_or_null("AnimationPlayer")
		if anim:
			anim.play("carta_flip")
			print("DEBUG: Animation 'carta_flip' iniciada en IA")
		else:
			# Fallback si no hay AnimationPlayer
			if carta_ia.has_method("flip_face_up"):
				carta_ia.flip_face_up()
		
		if carta_ia.has_method("revelar_color_elemental"):
			carta_ia.revelar_color_elemental(carta_ia.get_meta("tipo"))
	
	await get_tree().create_timer(1.0).timeout 

	var resultado = combate.determinar_resultado(carta_jugador, carta_ia)
	var ganador_global = combate.registrar_resultado(carta_jugador, carta_ia)

	match resultado:
		"jugador":
			if is_instance_valid(carta_jugador): 
				puntos_jugador.agregar_punto(carta_jugador.get_meta("tipo"))
				if carta_jugador.has_method("aplicar_efecto_victoria"):
					carta_jugador.aplicar_efecto_victoria()
			
			if is_instance_valid(carta_ia) and carta_ia.has_method("aplicar_efecto_derrota"):
				carta_ia.aplicar_efecto_derrota()
			
			if verificar_victoria_final("Jugador"): return
		"ia":
			if is_instance_valid(carta_ia): 
				puntos_ia.agregar_punto(carta_ia.get_meta("tipo"))
				if carta_ia.has_method("aplicar_efecto_victoria"):
					carta_ia.aplicar_efecto_victoria()
			
			if is_instance_valid(carta_jugador) and carta_jugador.has_method("aplicar_efecto_derrota"):
				carta_jugador.aplicar_efecto_derrota()
			
			if verificar_victoria_final("IA"): return
		"empate":
			if is_instance_valid(carta_jugador) and carta_jugador.has_method("aplicar_efecto_derrota"):
				carta_jugador.aplicar_efecto_derrota()
			if is_instance_valid(carta_ia) and carta_ia.has_method("aplicar_efecto_derrota"):
				carta_ia.aplicar_efecto_derrota()

	await get_tree().create_timer(1.2).timeout

	# LIMPIAR DINÁMICAMENTE
	if is_instance_valid(carta_jugador):
		if nodo_ranura_p: nodo_ranura_p.set_meta("carta_en_ranura", false)
		carta_jugador.queue_free()
	if is_instance_valid(carta_ia):
		if nodo_ranura_ia: nodo_ranura_ia.set_meta("carta_en_ranura", false)
		carta_ia.queue_free()

	# Limpiar estado de combate
	cartas_en_ranuras[ranura_id]["jugador"] = null
	cartas_en_ranuras[ranura_id]["ia"] = null
	cartas_en_ranuras[ranura_id]["nodo_player"] = null
	cartas_en_ranuras[ranura_id]["nodo_ia"] = null
	cartas_en_ranuras[ranura_id]["resolviendo"] = false # LIBERAR PARA PRÓXIMO COMBATE

	# Si es el carril central, limpiar también la ranura aliada para evitar bugs de registro
	if ranura_id == "ranuraplayer" and cartas_en_ranuras.has("ranuraia"):
		cartas_en_ranuras["ranuraia"]["ia"] = null
		cartas_en_ranuras["ranuraia"]["resolviendo"] = false

	# --- REINICIAR TURNO Y TEMPORIZADOR ---
	combate_en_curso = false
	iniciar_turno_jugador()

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
	
	var algun_combate = false
	# Resolver todos los carriles que tengan carta
	for ranura_id in cartas_en_ranuras.keys():
		if cartas_en_ranuras[ranura_id]["jugador"] and cartas_en_ranuras[ranura_id]["ia"]:
			algun_combate = true
			await comparar_cartas(ranura_id)
			
	combate_en_curso = false
	
	# Si no hubo combates, forzar el reinicio del turno para que el ciclo no se detenga
	if not algun_combate:
		print("⚔️ No se detectaron combates. Reiniciando ciclo de espera...")
		iniciar_turno_jugador()
	else:
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

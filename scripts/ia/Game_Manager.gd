extends Node
# --- Nodo central del juego (coordina jugador, IA y combate) ---

@onready var combate = preload("res://scripts/ia/combate.gd").new()
@onready var ia_controller = $"../BarajaIA/ManejoCartaIA"
@onready var player_controller = $"../baraja_player/ManejoCarta"
@onready var puntos_player = $"../baraja_player/puntos"
@onready var puntos_ia = $"../BarajaIA/puntos"

signal ronda_resultado(resultado: String)
signal partida_terminada(ganador: String)

func _ready():
	add_child(combate)
	combate.resetear_puntajes()
	
	print("✅ Game_Manager listo.")
	print("IA Controller:", ia_controller)
	print("Player Controller:", player_controller)
	print("Puntos Jugador:", puntos_player)
	print("Puntos IA:", puntos_ia)

func resolver_ronda(carta_jugador: Node, carta_ia: Node):
	var resultado_ronda = combate.determinar_resultado(carta_jugador, carta_ia)
	mostrar_resultado_visual(resultado_ronda, carta_jugador, carta_ia)
	emit_signal("ronda_resultado", resultado_ronda)

	var ganador = combate.registrar_resultado(carta_jugador, carta_ia)
	if ganador != "":
		emit_signal("partida_terminada", ganador)
		print("🏁 La partida terminó. Ganador:", ganador)

func mostrar_resultado_visual(resultado: String, carta_jugador: Node, carta_ia: Node) -> void:
	match resultado:
		"jugador_gana":
			carta_jugador.get_node("Cardimage").modulate = Color(1, 1, 1, 1)
			carta_ia.get_node("Cardimage").modulate = Color(0.5, 0.5, 0.5, 1)
			actualizar_puntos("jugador")
		"ia_gana":
			carta_ia.get_node("Cardimage").modulate = Color(1, 1, 1, 1)
			carta_jugador.get_node("Cardimage").modulate = Color(0.5, 0.5, 0.5, 1)
			actualizar_puntos("ia")
		"empate":
			carta_ia.get_node("Cardimage").modulate = Color(1, 1, 1, 1)
			carta_jugador.get_node("Cardimage").modulate = Color(1, 1, 1, 1)

	await get_tree().create_timer(1.2).timeout
	limpiar_cartas(carta_jugador, carta_ia)

func limpiar_cartas(carta_jugador: Node, carta_ia: Node):
	if is_instance_valid(carta_jugador):
		carta_jugador.queue_free()
	if is_instance_valid(carta_ia):
		carta_ia.queue_free()

func actualizar_puntos(quien: String):
	if quien == "jugador" and puntos_player:
		puntos_player.sumar_punto()
	elif quien == "ia" and puntos_ia:
		puntos_ia.sumar_punto()

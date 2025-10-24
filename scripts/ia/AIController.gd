
extends Node2D

@export var deck: Node
@export var manejo_carta: Node
@export var mano_jugador: Node

func _ready():
	# Conectarse a una señal de temporizador o de turno del juego
	# para activar la lógica de la IA.
	# Por ahora, usaremos un temporizador simple para probar.
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0
	timer.one_shot = false
	timer.start()
	timer.connect("timeout", _on_timer_timeout)

func _on_timer_timeout():
	# Lógica de la IA: decidir qué hacer.
	# Por ahora, la IA simplemente robará una carta si su mano no está llena.
	if mano_jugador.mano_jugador.size() < 5:
		deck.tomar_carta()

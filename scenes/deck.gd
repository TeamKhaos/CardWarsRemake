extends Node2D

var jugador_deck = ["planta", "planta", "planta"]
const carta_escena_dir = "res://scenes/card.tscn"
const velocidad_tomado_carta = 0.3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RichTextLabel.text = str(jugador_deck.size())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func tomar_carta():
	var carta_sacar = jugador_deck[0]
	jugador_deck.erase(carta_sacar)
	
	if jugador_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false

	$RichTextLabel.text = str(jugador_deck.size())

	var carta_escena = preload(carta_escena_dir)
	var nueva_carta = carta_escena.instantiate()
	$"../ManejoCarta".add_child(nueva_carta)
	nueva_carta.name = "Carta"
	$"../ManoJugador".añadir_carta_mano(nueva_carta, velocidad_tomado_carta)

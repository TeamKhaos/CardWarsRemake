extends Node2D

var jugador_deck = ["carta_verde1", "carta_roja1", "carta_azul1"]
const carta_escena_dir = "res://scenes/card.tscn"
const velocidad_tomado_carta = 0.3

var referencia_db_cartas

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	jugador_deck.shuffle()
	$RichTextLabel.text = str(jugador_deck.size())
	referencia_db_cartas = preload("res://scripts/DB_Cartas.gd")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func tomar_carta():
	var carta_sacar_nombre = jugador_deck[0]
	jugador_deck.erase(carta_sacar_nombre)
	
	if jugador_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false

	$RichTextLabel.text = str(jugador_deck.size())

	var carta_escena = preload(carta_escena_dir)
	var nueva_carta = carta_escena.instantiate()
	nueva_carta.get_node("ataque").text = str(referencia_db_cartas.CARTAS[carta_sacar_nombre][0])
	nueva_carta.get_node("defensa").text = str(referencia_db_cartas.CARTAS[carta_sacar_nombre][1])
	var carta_imagen_ruta = str("res://assets/" + carta_sacar_nombre + ".png") 
	
	#cargar imagenes y animaciones
	nueva_carta.get_node("Cardimage").texture = load(carta_imagen_ruta)
	$"../ManejoCarta".add_child(nueva_carta)
	nueva_carta.name = "Carta"
	$"../ManoJugador".añadir_carta_mano(nueva_carta, velocidad_tomado_carta)
	nueva_carta.get_node("AnimationPlayer").play("carta_flip")

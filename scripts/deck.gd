extends Node2D

# --- VARIABLES ---
# Un array que representa las cartas en el mazo del jugador.
var jugador_deck = ["planta", "planta", "planta"]
# Directorio de la escena de la carta.
const carta_escena_dir = "res://scenes/card.tscn"
# Velocidad a la que se toma la carta (actualmente 0).
const velocidad_tomado_carta = 0

# --- FUNCIONES DE GODOT ---
# Se llama cuando el nodo entra en el árbol de la escena por primera vez.
func _ready() -> void:
	# Actualiza la etiqueta de texto con el número de cartas en el mazo.
	$RichTextLabel.text = str(jugador_deck.size())


# --- FUNCIONES PERSONALIZADAS ---
# Se llama para que el jugador tome una carta del mazo.
func tomar_carta():
	# Toma la primera carta del mazo.
	var carta_sacar = jugador_deck[0]
	# Elimina la carta del mazo.
	jugador_deck.erase(carta_sacar)
	
	# Si el mazo se queda sin cartas, desactiva la colisión y oculta los elementos visuales.
	if jugador_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false

	# Actualiza la etiqueta de texto con el nuevo número de cartas.
	$RichTextLabel.text = str(jugador_deck.size())

	# Carga la escena de la carta.
	var carta_escena = preload(carta_escena_dir)
	# Crea una nueva instancia de la carta.
	var nueva_carta = carta_escena.instantiate()
	# Añade la nueva carta como hija del nodo "ManejoCarta".
	$"../ManejoCarta".add_child(nueva_carta)
	# Le da un nombre a la nueva carta.
	nueva_carta.name = "Carta"
	# Añade la carta a la mano del jugador.
	$"../ManoJugador".añadir_carta_mano(nueva_carta, velocidad_tomado_carta)
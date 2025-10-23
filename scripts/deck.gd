extends Node2D

# --- VARIABLES ---
# Array que contiene los nombres de las cartas en el mazo del jugador.
var jugador_deck = []
# Ruta a la escena de la carta.
const carta_escena_dir = "res://scenes/card.tscn"
# Velocidad de la animación al tomar una carta.
const velocidad_tomado_carta = 0.3
# Primer click
var primerclick = false

# Referencia a la base de datos de cartas.
var referencia_db_cartas

# --- FUNCIONES DE GODOT ---
# Se llama cuando el nodo entra en el árbol de la escena por primera vez.
func _ready() -> void:
	# Posiciona el mazo en el lado izquierdo de la pantalla.
	var tamano_ventana = get_viewport().size
	self.position = Vector2(tamano_ventana.x * 0.1, tamano_ventana.y * 0.8)
	var DbCartas = preload("res://scripts/DB_Cartas.gd")
	
	
	jugador_deck = DbCartas.CARTAS.keys()
	# Baraja el mazo del jugador.
	jugador_deck.shuffle()
	# Actualiza el texto que muestra el número de cartas en el mazo.
	$RichTextLabel.text = str(jugador_deck.size())
	# Carga la base de datos de cartas.
	referencia_db_cartas = preload("res://scripts/DB_Cartas.gd")

# --- FUNCIONES DEL MAZO ---
# Se llama para tomar una carta del mazo.
func tomar_carta():
	if primerclick == false:
		for i in range(5):
				# Obtiene el nombre de la carta a sacar.
			var carta_sacar_nombre = jugador_deck[0]
			# Elimina la carta del mazo.
			jugador_deck.erase(carta_sacar_nombre)
			# Actualiza el texto del contador de cartas.
			$RichTextLabel.text = str(jugador_deck.size())

			# Carga la escena de la carta.
			var carta_escena = preload(carta_escena_dir)
			# Instancia una nueva carta.
			var nueva_carta = carta_escena.instantiate()
			
			nueva_carta.global_position = self.global_position
			# Establece las estadísticas de la carta desde la base de datos.
			nueva_carta.get_node("ataque").text = str(referencia_db_cartas.CARTAS[carta_sacar_nombre][0])
			nueva_carta.get_node("defensa").text = str(referencia_db_cartas.CARTAS[carta_sacar_nombre][1])
			# Construye la ruta de la imagen de la carta.
			var carta_imagen_ruta = str("res://assets/" + carta_sacar_nombre + ".png") 
			
			# Carga la imagen y la asigna a la textura de la carta.
			nueva_carta.get_node("Cardimage").texture = load(carta_imagen_ruta)
			# Añade la nueva carta como hija del nodo de manejo de cartas.
			$"../ManejoCarta".add_child(nueva_carta)
			# Le da un nombre a la carta.
			nueva_carta.name = "Carta"
			# Añade la carta a la mano del jugador.
			$"../ManoJugador".añadir_carta_mano(nueva_carta, velocidad_tomado_carta)
			# Reproduce la animación de la carta al ser tomada.
			nueva_carta.get_node("AnimationPlayer").play("carta_flip")
			primerclick = true

func reponer_carta():
	

			# Obtiene el nombre de la carta a sacar.
		var carta_sacar_nombre = jugador_deck[0]
		# Elimina la carta del mazo.
		jugador_deck.erase(carta_sacar_nombre)
		# Si el mazo se queda vacío, desactiva la interacción y oculta los elementos visuales.
		if jugador_deck.size() == 0:
			$Area2D/CollisionShape2D.disabled = true
			$Sprite2D.visible = false
			$RichTextLabel.visible = false

		# Actualiza el texto del contador de cartas.
		$RichTextLabel.text = str(jugador_deck.size())

		# Carga la escena de la carta.
		var carta_escena = preload(carta_escena_dir)
		# Instancia una nueva carta.
		var nueva_carta = carta_escena.instantiate()
		
		nueva_carta.global_position = self.global_position
		# Establece las estadísticas de la carta desde la base de datos.
		nueva_carta.get_node("ataque").text = str(referencia_db_cartas.CARTAS[carta_sacar_nombre][0])
		nueva_carta.get_node("defensa").text = str(referencia_db_cartas.CARTAS[carta_sacar_nombre][1])
		# Construye la ruta de la imagen de la carta.
		var carta_imagen_ruta = str("res://assets/" + carta_sacar_nombre + ".png") 
		
		# Carga la imagen y la asigna a la textura de la carta.
		nueva_carta.get_node("Cardimage").texture = load(carta_imagen_ruta)
		# Añade la nueva carta como hija del nodo de manejo de cartas.
		$"../ManejoCarta".add_child(nueva_carta)
		# Le da un nombre a la carta.
		nueva_carta.name = "Carta"
		# Añade la carta a la mano del jugador.
		$"../ManoJugador".añadir_carta_mano(nueva_carta, velocidad_tomado_carta)
		# Reproduce la animación de la carta al ser tomada.
		nueva_carta.get_node("AnimationPlayer").play("carta_flip")
		primerclick = true

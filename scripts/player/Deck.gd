
extends Node2D

@export var is_player_one: bool = true
@export var manejo_carta: Node
@export var manejo_jugador: Node

# --- VARIABLES ---
var jugador_deck = []
const carta_escena_dir = "res://scenes/card.tscn"
const velocidad_tomado_carta = 0.3
var primerclick = false
var referencia_db_cartas

# --- FUNCIONES DE GODOT ---
func _ready() -> void:
	var tamano_ventana = get_viewport().size
	if is_player_one:
		self.position = Vector2(tamano_ventana.x * 0.20, tamano_ventana.y * 0.82)
	else:
		self.position = Vector2(tamano_ventana.x * 0.80, tamano_ventana.y * 0.18)
	
	var DbCartas = preload("res://scripts/DB_Cartas.gd")
	jugador_deck = DbCartas.CARTAS.keys()
	jugador_deck.shuffle()
	$RichTextLabel.text = str(jugador_deck.size())
	referencia_db_cartas = preload("res://scripts/DB_Cartas.gd")

# --- FUNCIONES DEL MAZO ---
func tomar_carta():
	if primerclick == false:
		for i in range(5):
			var carta_sacar_nombre = jugador_deck[0]
			jugador_deck.erase(carta_sacar_nombre)
			$RichTextLabel.text = str(jugador_deck.size())
			var carta_escena = preload(carta_escena_dir)
			var nueva_carta = carta_escena.instantiate()
			
			nueva_carta.global_position = self.global_position 
			
			var datos_carta = referencia_db_cartas.CARTAS[carta_sacar_nombre]
			nueva_carta.set_meta("ataque" , datos_carta["ataque"])
			nueva_carta.set_meta("tipo", datos_carta["tipo"]) # Guardamos el tipo como metadata (útil luego para el combate)
			
			var carta_imagen_ruta = str("res://assets/" + carta_sacar_nombre + ".png") 
			nueva_carta.get_node("Cardimage").texture = load(carta_imagen_ruta)
			manejo_carta.add_child(nueva_carta)
			nueva_carta.name = "Carta"
			manejo_jugador.añadir_carta_mano(nueva_carta, velocidad_tomado_carta)
			nueva_carta.get_node("AnimationPlayer").play("carta_flip")
			primerclick = true

func reponer_carta():
	if jugador_deck.size() > 0: 
		var carta_sacar_nombre = jugador_deck[0]
		jugador_deck.erase(carta_sacar_nombre)
		if jugador_deck.size() == 0:
			$Area2D/CollisionShape2D.disabled = true
			$Sprite2D.visible = false
			$RichTextLabel.visible = false
		$RichTextLabel.text = str(jugador_deck.size())
		var carta_escena = preload(carta_escena_dir)
		var nueva_carta = carta_escena.instantiate()
		nueva_carta.global_position = self.global_position
		
		var datos_carta = referencia_db_cartas.CARTAS[carta_sacar_nombre]
		nueva_carta.set_meta("ataque", datos_carta["ataque"])
		nueva_carta.set_meta("tipo", datos_carta["tipo"])

		var carta_imagen_ruta = str("res://assets/" + carta_sacar_nombre + ".png") 
		nueva_carta.get_node("Cardimage").texture = load(carta_imagen_ruta)
		manejo_carta.add_child(nueva_carta)
		nueva_carta.name = "Carta"		
		manejo_jugador.añadir_carta_mano(nueva_carta, velocidad_tomado_carta)
		nueva_carta.get_node("AnimationPlayer").play("carta_flip")

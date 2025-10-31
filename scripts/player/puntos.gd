extends Node2D

@export var is_player_one: bool = true


var indice_fuego = 0
var indice_agua = 0
var indice_planta = 0

# Posiciones de cada tipo
var posiciones_fuego = [Vector2(-103, -22), Vector2(-103, 26), Vector2(-103, 75)]
var posiciones_agua = [Vector2(101, -22), Vector2(101, 26), Vector2(101, 75)]
var posiciones_planta = [Vector2(-2, -22), Vector2(-2, 26), Vector2(-2, 75)]

func _ready():
	var tamano_ventana = get_viewport().size
	if is_player_one:
		position = Vector2(tamano_ventana.x * 0.87, tamano_ventana.y * 0.82)
	else:
		position = Vector2(tamano_ventana.x * 0.14, tamano_ventana.y * 0.18)


func agregar_punto(tipo: String):
	match tipo:
		"fuego":
			if indice_fuego < posiciones_fuego.size():
				# self es el nodo principal (el tablero)
				agregar_sprite(self, posiciones_fuego[indice_fuego], "res://assets/punto_roja.png")
				indice_fuego += 1
		"agua":
			if indice_agua < posiciones_agua.size():
				# self es el nodo principal (el tablero)
				agregar_sprite(self, posiciones_agua[indice_agua], "res://assets/punto_azul.png")
				indice_agua += 1
		"planta":
			if indice_planta < posiciones_planta.size():
				# self es el nodo principal (el tablero)
				agregar_sprite(self, posiciones_planta[indice_planta], "res://assets/punto_verde.png")
				indice_planta += 1

func agregar_sprite(parent_node: Node, pos: Vector2, texture_path: String):
	var sprite = Sprite2D.new()
	sprite.texture = load(texture_path)
	sprite.position = pos
	sprite.scale = Vector2(0.1, 0.1) 
	self.add_child(sprite)

extends Node2D

@export var is_player_one: bool = true

# Precarga de shaders
const ELEGANT_TABLE_SHADER = preload("res://assets/shaders/elegant_table.gdshader")
const POINT_SHADER = preload("res://assets/shaders/point_energy.gdshader")

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
	
	# Aplicar shader elegante a la tabla
	var tabla = get_node_or_null("tabla")
	if tabla:
		var mat = ShaderMaterial.new()
		mat.shader = ELEGANT_TABLE_SHADER
		mat.set_shader_parameter("rim_color", Color(1, 1, 1, 0.4))
		mat.set_shader_parameter("rim_width", 0.1)
		mat.set_shader_parameter("pulse_speed", 0.8)
		mat.set_shader_parameter("pulse_intensity", 0.02)
		mat.set_shader_parameter("vignette_intensity", 0.15)
		tabla.material = mat

func agregar_punto(tipo: String):
	match tipo:
		"fuego":
			if indice_fuego < posiciones_fuego.size():
				agregar_sprite(posiciones_fuego[indice_fuego], "res://assets/punto_roja.png")
				indice_fuego += 1
		"agua":
			if indice_agua < posiciones_agua.size():
				agregar_sprite(posiciones_agua[indice_agua], "res://assets/punto_azul.png")
				indice_agua += 1
		"planta":
			if indice_planta < posiciones_planta.size():
				agregar_sprite(posiciones_planta[indice_planta], "res://assets/punto_verde.png")
				indice_planta += 1

func agregar_sprite(pos: Vector2, texture_path: String):
	var sprite = Sprite2D.new()
	sprite.texture = load(texture_path)
	sprite.position = pos
	sprite.scale = Vector2.ZERO # Empezamos desde cero para la animación
	
	# Aplicar shader de energía al punto
	var mat = ShaderMaterial.new()
	mat.shader = POINT_SHADER
	sprite.material = mat
	
	add_child(sprite)
	
	# Animación de aparición (Tween)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(0.1, 0.1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate", Color(2, 2, 2), 0.2) # Flash de brillo
	
	# Volver al modulate normal después del flash
	var tween_back = create_tween()
	tween_back.tween_interval(0.2)
	tween_back.tween_property(sprite, "modulate", Color(1, 1, 1), 0.3)

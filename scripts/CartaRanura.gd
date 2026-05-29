extends Node2D

@export var id_ranura: String = ""
@export var primersloot: bool = true
var carta_en_ranura = false

const SLOT_SHADER = preload("res://assets/shaders/slot_energy.gdshader")

func _ready() -> void:
	var tamano_ventana = get_viewport().size
	if primersloot:
		self.position = Vector2(tamano_ventana.x * 0.39, tamano_ventana.y * 0.5)
		id_ranura = "ranuraplayer"
	else:
		self.position = Vector2(tamano_ventana.x * 0.61, tamano_ventana.y * 0.5)
		id_ranura = "ranuraia"
	
	set_meta("id_ranura", id_ranura)
	set_meta("es_ia", !primersloot)
	set_meta("carta_en_ranura", carta_en_ranura)
	
	# Aplicar shader de energía a la ranura
	var img = get_node_or_null("CartaRanuraImg")
	if img:
		var mat = ShaderMaterial.new()
		mat.shader = SLOT_SHADER
		mat.set_shader_parameter("line_color", Color(1.0, 1.0, 1.0, 0.6))
		mat.set_shader_parameter("is_occupied", 0.0)
		img.material = mat

func _process(_delta):
	# Actualizar el shader basándose en si hay una carta (vía metadata para sincronizar con GM)
	var ocupada = get_meta("carta_en_ranura", false)
	var img = get_node_or_null("CartaRanuraImg")
	if img and img.material is ShaderMaterial:
		img.material.set_shader_parameter("is_occupied", 1.0 if ocupada else 0.0)

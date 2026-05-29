extends Label

const VS_SHADER = preload("res://assets/shaders/vs_style.gdshader")

func _ready() -> void:
	# 1. Posicionamiento Responsivo (Centro exacto de la pantalla)
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Centrar el pivote para que la posición (0.5, 0.5) sea el centro real del texto
	pivot_offset = size / 2.0
	position = Vector2(viewport_size.x * 0.5, viewport_size.y * 0.5) - (size / 2.0)
	
	# 2. Aplicar Shader de estilo
	var mat = ShaderMaterial.new()
	mat.shader = VS_SHADER
	mat.set_shader_parameter("text_color", Color(1, 1, 1, 1))
	mat.set_shader_parameter("shine_speed", 1.5)
	mat.set_shader_parameter("glow_amount", 1.2)
	self.material = mat

func _process(_delta: float) -> void:
	# Mantener centrado si la ventana cambia de tamaño (opcional pero recomendado)
	var viewport_size = get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x * 0.5, viewport_size.y * 0.375) - (size / 2.0)

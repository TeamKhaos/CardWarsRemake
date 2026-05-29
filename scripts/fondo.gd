extends ParallaxBackground

const BACKGROUND_SHADER = preload("res://assets/shaders/background_ambience.gdshader")

func _ready() -> void:
	ajustar_fondo()
	get_viewport().connect("size_changed", Callable(self, "ajustar_fondo"))
	
	# Aplicar shader de ambiente al fondo
	var fondo_sprite = $ParallaxLayer/Sprite2D
	if fondo_sprite:
		var mat = ShaderMaterial.new()
		mat.shader = BACKGROUND_SHADER
		mat.set_shader_parameter("vignette_intensity", 0.5)
		mat.set_shader_parameter("nebula_speed", 0.05)
		mat.set_shader_parameter("nebula_opacity", 0.1)
		fondo_sprite.material = mat

func ajustar_fondo() -> void:
	var fondo_sprite = $ParallaxLayer/Sprite2D
	
	if fondo_sprite.texture:
		var tamano_ventana = get_viewport().size
		var tamano_textura = fondo_sprite.texture.get_size()
		
		# Escala la textura para llenar toda la pantalla
		fondo_sprite.scale = Vector2(tamano_ventana) / tamano_textura
		fondo_sprite.position = tamano_ventana / 2

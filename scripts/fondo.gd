extends ParallaxBackground

func _ready() -> void:
	ajustar_fondo()
	get_viewport().connect("size_changed", Callable(self, "ajustar_fondo"))

func ajustar_fondo() -> void:
	var fondo_sprite = $ParallaxLayer/Sprite2D
	
	if fondo_sprite.texture:
		var tamano_ventana = get_viewport().size
		var tamano_textura = fondo_sprite.texture.get_size()
		
		# Escala la textura para llenar toda la pantalla
		fondo_sprite.scale = Vector2(tamano_ventana) / tamano_textura
		fondo_sprite.position = tamano_ventana / 2

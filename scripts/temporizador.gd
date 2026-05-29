extends AnimatedSprite2D

signal tiempo_agotado

const TIMER_SHADER = preload("res://assets/shaders/timer_magic.gdshader")

func _ready():
	# 1. Posicionamiento Responsivo
	# Basado en tu posición original (1437, 444) en una pantalla estándar (asumiendo 1920x1080)
	# Eso es aproximadamente el 75% horizontal y 41% vertical.
	var viewport_size = get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x * 0.5, viewport_size.y * 0.5)
	
	# 2. Aplicar Shader Mágico
	var mat = ShaderMaterial.new()
	mat.shader = TIMER_SHADER
	mat.set_shader_parameter("line_color", Color(1.0, 1.0, 1.0, 1.0)) # Blanco Puro
	mat.set_shader_parameter("speed", 4.0)
	mat.set_shader_parameter("line_thickness", 0.03)
	self.material = mat
	
	# 3. Configuración inicial
	frame = 0
	stop()
	
	# Conectar la señal de fin de animación
	animation_finished.connect(_on_animation_finished)

func iniciar_cuenta_regresiva():
	play("temporizador")
	print("⏱️ Temporizador iniciado.")

func detener_temporizador():
	stop()
	frame = 0

func _on_animation_finished():
	if animation == "temporizador":
		print("⏱️ ¡Tiempo agotado!")
		emit_signal("tiempo_agotado")

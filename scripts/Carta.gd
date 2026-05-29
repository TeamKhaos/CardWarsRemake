extends Node2D

# --- PROPIEDADES ---
@export var is_ai: bool = false
var is_in_hand: bool = false

# --- SEÑALES ---
# Se emite cuando el mouse está sobre la carta.
signal sosteniendo
# Se emite cuando el mouse deja de estar sobre la carta.
signal soltando

# --- VARIABLES ---
# Almacena la posición inicial de la carta para poder devolverla a su lugar.
var posicion_inicial
var hover_amount: float = 0.0
var target_hover: float = 0.0
var idle_amount: float = 0.0
var mouse_rel_pos: Vector2 = Vector2(0.5, 0.5)

# --- FUNCIONES DE VOLTEO ---
func flip_face_up():
	var img = get_node_or_null("Cardimage")
	if img: 
		img.visible = true
		img.z_index = 1
	var reverso = get_node_or_null("Carta_reverso")
	if reverso:
		reverso.z_index = 0

func flip_face_down():
	var img = get_node_or_null("Cardimage")
	if img: 
		img.visible = false
		img.z_index = -1
	var reverso = get_node_or_null("Carta_reverso")
	if reverso:
		reverso.z_index = 1

# --- EFECTOS VISUALES ---
const CARD_DYNAMIC_SHADER = """
shader_type canvas_item;

uniform vec2 velocity = vec2(0.0);
uniform float hover_amount = 0.0;
uniform float idle_amount = 0.0;
uniform vec2 mouse_pos = vec2(0.5);
uniform float time_offset = 0.0;

void vertex() {
	// 1. Efecto de flotación (Idle + Hover)
	float total_float = max(idle_amount * 0.4, hover_amount);
	float float_cycle = sin(TIME * 2.0 + time_offset) * 8.0 * total_float;
	VERTEX.y += float_cycle;
	
	// 2. Inclinación por posición del mouse (Parallax)
	float parallax_x = (mouse_pos.x - 0.5) * (UV.y - 0.5) * 40.0 * hover_amount;
	float parallax_y = (mouse_pos.y - 0.5) * (UV.x - 0.5) * 40.0 * hover_amount;
	VERTEX.x += parallax_x;
	VERTEX.y += parallax_y;
	
	// 3. Inclinación física por movimiento (Drag)
	VERTEX.x += velocity.x * (UV.y - 0.5) * 100.0;
	VERTEX.y += velocity.y * (UV.x - 0.5) * 100.0;
	
	// 4. Balanceo (Rotation) sutil constante
	float roll = cos(TIME * 1.5 + time_offset) * 0.04 * total_float;
	float s = sin(roll);
	float c = cos(roll);
	VERTEX = mat2(vec2(c, -s), vec2(s, c)) * VERTEX;
}

void fragment() {
	// Solo aplicamos la textura original y el modulate (COLOR)
	COLOR = texture(TEXTURE, UV) * COLOR;
}
"""

const AURA_SHADER = """
shader_type canvas_item;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
	// Crear líneas de "relámpago" usando ondas senoidales
    float time = TIME * 5.0;
    float line = sin(UV.y * 20.0 + time) * 0.5 + 0.5;
    line += sin(UV.x * 20.0 - time) * 0.5 + 0.5;
    
    // Multiplicamos por COLOR para que el 'modulate' (color elemental) se preserve
    COLOR = tex * COLOR * vec4(1.0, 1.0, 1.0, line * 0.5 + 0.5);
}
"""

func setup_dynamic_shader():
	var mat = ShaderMaterial.new()
	var shader = Shader.new()
	shader.code = CARD_DYNAMIC_SHADER
	mat.shader = shader
	
	# Offset de tiempo aleatorio para que no todas las cartas floten igual
	mat.set_shader_parameter("time_offset", randf() * 10.0)
	
	var img = get_node_or_null("Cardimage")
	if img: img.material = mat
	
	var reverso = get_node_or_null("Carta_reverso")
	if reverso: reverso.material = mat

func set_drag_velocity(vel: Vector2):
	var img = get_node_or_null("Cardimage")
	if img and img.material is ShaderMaterial:
		img.material.set_shader_parameter("velocity", vel)
	
	var reverso = get_node_or_null("Carta_reverso")
	if reverso and reverso.material is ShaderMaterial:
		reverso.material.set_shader_parameter("velocity", vel)

func update_shader_uniforms():
	var img = get_node_or_null("Cardimage")
	if img and img.material is ShaderMaterial:
		img.material.set_shader_parameter("hover_amount", hover_amount)
		img.material.set_shader_parameter("idle_amount", idle_amount)
		img.material.set_shader_parameter("mouse_pos", mouse_rel_pos)
	
	var reverso = get_node_or_null("Carta_reverso")
	if reverso and reverso.material is ShaderMaterial:
		reverso.material.set_shader_parameter("hover_amount", hover_amount)
		reverso.material.set_shader_parameter("idle_amount", idle_amount)
		reverso.material.set_shader_parameter("mouse_pos", mouse_rel_pos)

func aplicar_brillo_elemental(tipo: String, es_oculta: bool = false):
	var aura = get_node_or_null("AuraSprite")
	if not aura: return
	
	aura.visible = true
	
	# Si es oculta, usamos blanco. Si no, usamos el color del elemento.
	if es_oculta:
		aura.modulate = Color(1.0, 1.0, 1.0)
	else:
		match tipo:
			"fuego":  aura.modulate = Color(1.0, 0.3, 0.2)
			"agua":   aura.modulate = Color(0.2, 0.6, 1.0)
			"planta": aura.modulate = Color(0.3, 1.0, 0.3)
	
	# Aplicar shader de relámpago
	var material = ShaderMaterial.new()
	var shader = Shader.new()
	shader.code = AURA_SHADER
	material.shader = shader
	aura.material = material

func revelar_color_elemental(tipo: String):
	var aura = get_node_or_null("AuraSprite")
	if aura:
		match tipo:
			"fuego":  aura.modulate = Color(1.0, 0.3, 0.2)
			"agua":   aura.modulate = Color(0.2, 0.6, 1.0)
			"planta": aura.modulate = Color(0.3, 1.0, 0.3)


# --- FUNCIONES DE GODOT ---
func _ready() -> void:
	add_to_group("cartas")
	setup_dynamic_shader()
	# Forzar un Z-index alto para estar siempre por encima de las ranuras
	z_index = 5
	
	# Si la carta es de la IA, deshabilitar la interacción del mouse.
	if is_ai:
		var area_2d = get_node_or_null("Area2D")
		if area_2d:
			area_2d.input_pickable = false
		
		# Asegurar que empiece boca abajo
		flip_face_down()
	else:
		# Por defecto, las cartas que no son de la IA empiezan en la mano
		is_in_hand = true

	if get_parent().has_method("connect_carta_signal"):
		get_parent().connect_carta_signal(self)


func _process(delta: float) -> void:
	# Suavizar la transición del hover
	hover_amount = lerp(hover_amount, target_hover, delta * 8.0)
	
	# Suavizar el idle si está en la mano
	var target_idle = 1.0 if is_in_hand else 0.0
	idle_amount = lerp(idle_amount, target_idle, delta * 4.0)
	
	if target_hover > 0.1:
		# Calcular posición relativa del mouse sobre la carta (0.0 a 1.0)
		var local_mouse = get_local_mouse_position()
		# Asumimos un tamaño base de la carta de aprox 160x250 (según CollisionShape)
		mouse_rel_pos.x = clamp((local_mouse.x + 80.0) / 160.0, 0.0, 1.0)
		mouse_rel_pos.y = clamp((local_mouse.y + 125.0) / 250.0, 0.0, 1.0)
	
	update_shader_uniforms()

# --- CONEXIONES DE SEÑALES ---
func _on_area_2d_mouse_entered() -> void:
	target_hover = 1.0
	emit_signal("sosteniendo", self)


func _on_area_2d_mouse_exited() -> void:
	target_hover = 0.0
	emit_signal("soltando", self)

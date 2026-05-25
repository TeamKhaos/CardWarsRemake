extends Node2D

# --- PROPIEDADES ---
@export var is_ai: bool = false

# --- SEÑALES ---
# Se emite cuando el mouse está sobre la carta.
signal sosteniendo
# Se emite cuando el mouse deja de estar sobre la carta.
signal soltando

# --- VARIABLES ---
# Almacena la posición inicial de la carta para poder devolverla a su lugar.
var posicion_inicial

# --- FUNCIONES DE VOLTEO ---
func flip_face_up():
	var img = get_node_or_null("Cardimage")
	if img: img.visible = true

func flip_face_down():
	var img = get_node_or_null("Cardimage")
	if img: img.visible = false

# --- EFECTOS VISUALES ---
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
	# Si la carta es de la IA, deshabilitar la interacción del mouse.
	if is_ai:
		var area_2d = get_node_or_null("Area2D") # Asume que el nodo Area2D se llama "Area2D"
		if area_2d:
			area_2d.input_pickable = false
		
		# Asegurar que empiece boca abajo
		flip_face_down()

	# Conecta las señales de esta carta al script del padre (ManejoCarta).
	# Es importante que todas las cartas sean hijas de ManejoCarta para que esto funcione.
	if get_parent().has_method("connect_carta_signal"):
		get_parent().connect_carta_signal(self)


# Se llama en cada fotograma. 'delta' es el tiempo transcurrido desde el fotograma anterior.
func _process(delta: float) -> void:
	# Esta función está vacía, pero se puede usar para actualizar el estado de la carta.
	pass

# --- CONEXIONES DE SEÑALES ---
# Se llama cuando el cursor del mouse entra en el área de la carta.
func _on_area_2d_mouse_entered() -> void:
	# Emite la señal "sosteniendo", pasando la propia carta como argumento.
	emit_signal("sosteniendo", self)


# Se llama cuando el cursor del mouse sale del área de la carta.
func _on_area_2d_mouse_exited() -> void:
	# Emite la señal "soltando", pasando la propia carta como argumento.
	emit_signal("soltando", self)

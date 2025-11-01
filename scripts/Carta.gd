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

# --- FUNCIONES DE GODOT ---
# Se llama cuando el nodo entra en el árbol de la escena por primera vez.
func _ready() -> void:
	# Si la carta es de la IA, deshabilitar la interacción del mouse.
	if is_ai:
		var area_2d = get_node_or_null("Area2D") # Asume que el nodo Area2D se llama "Area2D"
		if area_2d:
			area_2d.input_pickable = false
		
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

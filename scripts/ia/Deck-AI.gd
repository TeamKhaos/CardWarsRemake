extends Node2D

@export var is_player_one: bool = true
@export var manejo_carta: Node
@export var manejo_ia: Node
var ALTURA_DEFECTO_CARTA: float
var es_primera_toma = true
# --- VARIABLES ---
var ia_deck = []
const carta_escena_dir = "res://scenes/card.tscn"
const velocidad_tomado_carta = 0.3
var primerclick = false
var referencia_db_cartas
# --- FUNCIONES DE GODOT ---
func _ready() -> void:
	ALTURA_DEFECTO_CARTA =0.7
	
	var tamano_ventana = get_viewport().size
	if is_player_one:
		self.position = Vector2(tamano_ventana.x * 0.20, tamano_ventana.y * 0.82)
	else:
		self.position = Vector2(tamano_ventana.x * 0.80, tamano_ventana.y * 0.18)
	
	var DbCartas = preload("res://scripts/DB_Cartas.gd")
	referencia_db_cartas = DbCartas
	ia_deck = DbCartas.CARTAS.keys()
	ia_deck.shuffle()

# --- FUNCIONES DEL MAZO ---
func tomar_carta():
	if ia_deck.is_empty():
		return
	
	var cantidad_a_sacar = 1 # Por defecto, saca 1 carta
	
	if es_primera_toma:
		cantidad_a_sacar = 5 # Si es la primera vez, saca 5
		es_primera_toma = false # ¡Importante! Cambia el estado para las siguientes llamadas
	
	for i in range(cantidad_a_sacar):
		if ia_deck.is_empty():
			break # Salir si el mazo se vacía
			
		var carta_sacar_nombre = ia_deck.pop_front() # Usar pop_front() es más eficiente para un "mazo"
		# Nota: En tu código original usabas erase(nombre), que elimina por valor y es menos eficiente
		# Te recomiendo usar pop_front() si 'ia_deck' es un Array (y mantiene el orden de mazo)
		# Si quieres mantener tu lógica original de 'erase':
		# var carta_sacar_nombre = ia_deck[0]
		# ia_deck.erase(carta_sacar_nombre) # Si tienes nombres duplicados, esto borrará la primera ocurrencia

		
		$RichTextLabel.text = str(ia_deck.size())
		var carta_escena = preload(carta_escena_dir)
		var nueva_carta = carta_escena.instantiate()


		nueva_carta.is_ai = true
		nueva_carta.global_position = self.global_position
		# Ajusta la escala si es necesario, asegúrate de que ALTURA_DEFECTO_CARTA esté definida
		nueva_carta.scale = Vector2(ALTURA_DEFECTO_CARTA, ALTURA_DEFECTO_CARTA)
		
		var datos_carta = referencia_db_cartas.CARTAS[carta_sacar_nombre]
		nueva_carta.set_meta("ataque", datos_carta["ataque"])
		nueva_carta.set_meta("tipo", datos_carta["tipo"])
		nueva_carta.aplicar_brillo_elemental(datos_carta["tipo"], true)

		var carta_imagen_ruta = str("res://assets/" + carta_sacar_nombre + ".png")
		nueva_carta.get_node("Cardimage").texture = load(carta_imagen_ruta)
		
		manejo_carta.add_child(nueva_carta)
		nueva_carta.name = "Carta" + str(i) # Es bueno dar nombres únicos
		
		# Asegúrate de que velocidad_tomado_carta esté definida
		manejo_ia.añadir_carta_mano(nueva_carta, velocidad_tomado_carta)
			
			

extends Control

# Asegúrate de que estos nombres de nodo coincidan con los de tu escena
@onready var texture_ganaste: TextureRect = $Ganaste
@onready var texture_perdiste: TextureRect = $Perdiste
@onready var texture_empate: TextureRect = $Empate

# Variable para guardar el resultado antes de que _ready lo muestre
var resultado_a_mostrar: String = ""

# --- Función Principal para Mostrar el Resultado (Ahora solo prepara el dato) ---
func mostrar_resultado(ganador: String):
	# Ya NO pausamos aquí. Solo guardamos el resultado.
	resultado_a_mostrar = ganador
	
	# Oculta todos por defecto (Puedes dejar esto, aunque se repetirá en _ready)
	texture_ganaste.visible = false
	texture_perdiste.visible = false
	texture_empate.visible = false
	
	# NO TOCAR el resto de este bloque. La lógica de mostrar debe ir en _ready.


func _ready() -> void:
	# 1. ¡PAUSAR AQUÍ! El nodo ya está en el árbol y get_tree() es válido.
	get_tree().paused = true
	
	# 2. Ahora sí, ejecuta la lógica de mostrar el mensaje.
	_mostrar_mensaje_final(resultado_a_mostrar)


# Función auxiliar que contiene la lógica de mostrar/ocultar los TextureRects
func _mostrar_mensaje_final(ganador: String):
	print("Mostrando resultado:", ganador)

	# Muestra solo el TextureRect correspondiente
	match ganador:
		"Jugador":
			texture_ganaste.visible = true
		"IA":
			texture_perdiste.visible = true 
		"Empate":
			texture_empate.visible = true
		_:
			print("Error: Resultado no reconocido:", ganador)

# (Agregar función de reiniciar/salir aquí si es necesario)

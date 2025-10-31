extends Control

@onready var texture_ganaste: TextureRect = $Ganaste
@onready var texture_perdiste: TextureRect = $Perdiste
@onready var texture_empate: TextureRect = $Empate

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _ready() -> void:
	texture_ganaste.visible = false
	texture_perdiste.visible = false
	texture_empate.visible = false


func mostrar_resultado(ganador: String):
	print("Mostrando resultado:", ganador)
	match ganador:
		"Jugador":
			texture_ganaste.visible = true
		"IA":
			texture_perdiste.visible = true 
		"Empate":
			texture_empate.visible = true
		_:
			print("Error: Resultado no reconocido:", ganador)

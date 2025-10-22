extends Node2D

signal sosteniendo
signal soltando

var posicion_inicial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Todas las cartas son hijos ahora de ManejoCarta o esto darra error
	get_parent().connect_carta_signal(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	emit_signal("sosteniendo", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("soltando", self)

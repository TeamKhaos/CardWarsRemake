extends Node2D

const MASCARA_COLISION_CARTA = 1
const MASCARA_COLISION_CARTA_DECK = 4
var carta_manager_referencia
var deck_referencia

signal clickeado_click_izquierdo
signal levantado_click_izquierdo


func _ready() -> void:
	carta_manager_referencia = $"../ManejoCarta"
	deck_referencia = $"../Deck"

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("clickeado_click_izquierdo")
			raycast_al_cursor()
		else:
			emit_signal("levantado_click_izquierdo")
			

func raycast_al_cursor():
	var space_state = get_world_2d().direct_space_state
	var parametros = PhysicsPointQueryParameters2D.new()
	parametros.position = get_global_mouse_position()
	parametros.collide_with_areas = true
	var resultado = space_state.intersect_point(parametros)
	if resultado.size() > 0:
		var resultado_collision_mask = resultado[0].collider.collision_mask
		if resultado_collision_mask == MASCARA_COLISION_CARTA:
			#carta seleccionada
			var carta_encontrada = resultado[0].collider.get_parent()
			if carta_encontrada:
				carta_manager_referencia.empezar_a_arrastrar(carta_encontrada)
		elif resultado_collision_mask == MASCARA_COLISION_CARTA_DECK:
			#deck seleccionado
			deck_referencia.tomar_carta()

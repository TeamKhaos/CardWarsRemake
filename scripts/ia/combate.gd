extends Node

# --- Sistema de combate tipo CardJitsu ---

# Definición de ventajas elementales
var ventajas = {
	"fuego": "planta",
	"agua": "fuego",
	"planta": "agua"
}

# Tipos de victoria posibles
enum WinMode { SAME_ELEMENT, TOTAL_POINTS, ALL_ELEMENTS }

# --- Variables de puntuación ---
var puntos_jugador = {"fuego":0, "agua":0, "planta":0}
var puntos_ia      = {"fuego":0, "agua":0, "planta":0}
var puntos_totales_jugador := 0
var puntos_totales_ia := 0

# --- Configuración de reglas ---
var WIN_MODE = WinMode.SAME_ELEMENT
var WIN_THRESHOLD = 3
var ALL_ELEMENTS_THRESHOLD = 1

# --- Función principal ---
func determinar_resultado(carta_jugador: Node, carta_ia: Node) -> String:
	var tipo_jugador = carta_jugador.get_meta("tipo")
	var tipo_ia = carta_ia.get_meta("tipo")
	var ataque_jugador = carta_jugador.get_meta("ataque")
	var ataque_ia = carta_ia.get_meta("ataque")

	if tipo_jugador == tipo_ia:
		if ataque_jugador > ataque_ia:
			return "jugador"
		elif ataque_jugador < ataque_ia:
			return "ia"
		else:
			return "empate"
	elif ventajas[tipo_jugador] == tipo_ia:
		return "jugador"
	else:
		return "ia"

func registrar_resultado(carta_jugador: Node, carta_ia: Node) -> String:
	var resultado = determinar_resultado(carta_jugador, carta_ia)
	var tipo_jugador = carta_jugador.get_meta("tipo")
	var tipo_ia = carta_ia.get_meta("tipo")

	match resultado:
		"jugador":
			puntos_totales_jugador += 1
			puntos_jugador[tipo_jugador] += 1
		"ia":
			puntos_totales_ia += 1
			puntos_ia[tipo_ia] += 1

	return comprobar_victoria()

func comprobar_victoria() -> String:
	if WIN_MODE == WinMode.SAME_ELEMENT:
		for tipo in puntos_jugador.keys():
			if puntos_jugador[tipo] >= WIN_THRESHOLD:
				return "jugador"
		for tipo in puntos_ia.keys():
			if puntos_ia[tipo] >= WIN_THRESHOLD:
				return "ia"

	elif WIN_MODE == WinMode.TOTAL_POINTS:
		if puntos_totales_jugador >= WIN_THRESHOLD:
			return "jugador"
		if puntos_totales_ia >= WIN_THRESHOLD:
			return "ia"

	elif WIN_MODE == WinMode.ALL_ELEMENTS:
		var jugador_ok = true
		var ia_ok = true
		for tipo in puntos_jugador.keys():
			if puntos_jugador[tipo] < ALL_ELEMENTS_THRESHOLD:
				jugador_ok = false
			if puntos_ia[tipo] < ALL_ELEMENTS_THRESHOLD:
				ia_ok = false
		if jugador_ok:
			return "jugador"
		if ia_ok:
			return "ia"
	return ""

func resetear_puntajes():
	puntos_jugador = {"fuego":0, "agua":0, "planta":0}
	puntos_ia = {"fuego":0, "agua":0, "planta":0}
	puntos_totales_jugador = 0
	puntos_totales_ia = 0

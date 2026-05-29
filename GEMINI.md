# Mapa Técnico Detallado - Card Wars Remake (GODOT)

Este documento proporciona una guía exhaustiva de la arquitectura del código, funciones clave con referencias de línea y sistemas de interacción.

---

## 1. Núcleo: `scripts/Carta.gd`
Controla el comportamiento individual de cada carta, sus efectos visuales y respuesta al mouse.

- **Línea 21: `flip_face_up()`**: Hace visible el nodo `Cardimage` y ajusta el `z_index` para mostrar el frente.
- **Línea 31: `flip_face_down()`**: Oculta el frente y muestra el reverso (`Carta_reverso`).
- **Línea 40: `CARD_DYNAMIC_SHADER`**: Shader de vértices que maneja:
	- *Idle Float*: Balanceo suave (Línea 49).
	- *Parallax*: Inclinación basada en la posición del mouse (Línea 55).
	- *Drag Velocity*: Inclinación física al arrastrar (Línea 61).
- **Línea 76: `setup_dynamic_shader()`**: Instancia y configura el `ShaderMaterial` dinámico con un offset de tiempo aleatorio.
- **Línea 110: `aplicar_brillo_elemental(tipo, es_oculta)`**: Inicializa el `AURA_SHADER`. Si la carta es de la IA (`es_oculta`), el brillo es blanco neutro.
- **Línea 130: `revelar_color_elemental(tipo)`**: Cambia el `modulate` del aura al color real (Fuego: Rojo, Agua: Azul, Planta: Verde).
- **Línea 158: `_process(delta)`**: Interpola (`lerp`) los valores de `hover_amount` e `idle_amount` para animaciones fluidas.

---

## 2. Coordinación: `scripts/ia/Game_Manager.gd`
Nodo central que gestiona el flujo del combate, turnos y registro de estado.

- **Línea 32: `senal_reparto_terminado(es_ia)`**: Sincroniza el inicio del combate tras el reparto automático de ambos bandos.
- **Línea 49: `registrar_carta(ranura_id, carta, es_ia)`**:
	- Almacena referencias de cartas en el diccionario `cartas_en_ranuras`.
	- Detecta si la ranura es de combate central (`ranuraplayer`/`ranuraia`) para iniciar el duelo central.
- **Línea 103: `comparar_cartas_centrales()`**: Gestiona el bucle de combate en el carril central, solicitando reposición a la IA tras cada duelo.
- **Línea 144: `comparar_cartas(ranura_id)`**:
	- **Línea 160**: Revelado simultáneo de cartas.
	- **Línea 174**: Consulta a `combate.gd` para el resultado elemental.
	- **Línea 193**: Limpieza de cartas y liberación de ranuras tras el combate.
- **Línea 215: `iniciar_combate_total()`**: Se activa por timeout del cronómetro (20s), resolviendo todos los carriles KHAOS ocupados.
- **Línea 227: `verificar_victoria_final()`**: Evalúa si alguien alcanzó 3 puntos del mismo elemento o 1 de cada uno.

---

## 3. Sistema KHAOS: `scripts/player/ranuras.gd`
Transforma sprites estáticos en ranuras funcionales interactivas.

- **Línea 9: `inicializar_ranuras_khaos()`**: 
	- Posiciona los nodos K-H-A-O-S dinámicamente según el tamaño de la pantalla.
	- **Línea 33**: Inyecta **Metadata** (`id_ranura`, `es_ia`) a los nodos.
	- **Línea 43**: Crea en tiempo de ejecución nodos `Area2D` y `CollisionShape2D` para detectar colisiones de arrastre.

---

## 4. Controladores de Arrastre: `scripts/player/Player-Controller.gd`
Gestiona la interacción física del jugador con las cartas.

- **Línea 58: `empezar_a_arrastrar(carta)`**: Inicia el seguimiento del mouse y escala la carta.
- **Línea 71: `dejar_de_arrastrar()`**:
	- **Línea 103: Caso Intercambio (Swap)**: Si se suelta sobre otra carta en KHAOS, intercambian posiciones.
	- **Línea 136: Caso Registro**: Si es una ranura vacía, se registra en el `Game_Manager`.
	- **Línea 147: Bloqueo Central**: Si la carta entra en `ranuraplayer`, se desactiva su `input_pickable` y se pide reposición al mazo.
- **Línea 181: `volver_a_casa(carta)`**: Tween de retorno a la posición inicial si el movimiento es inválido.
- **Línea 231: `raycast_check_carta()`**: Identifica la carta bajo el mouse priorizando por `z_index`.

---

## 5. Automatización: `scripts/player/Deck.gd` y `scripts/ia/Deck-AI.gd`
Gestionan el mazo y la distribución inicial.

- **Línea 37 (`Deck.gd`): `repartir_a_ranuras()`**: Distribuye visualmente las cartas iniciales a las posiciones KHAOS del jugador.
- **Línea 77 (`Deck.gd`): `reponer_carta_en_ranura(ranura)`**: Instancia una nueva carta del mazo cuando una ranura de la mano queda vacía.
- **Línea 33 (`Deck-AI.gd`): `repartir_a_ranuras_ia()`**: Reparte las 5 cartas KHAOS y la carta central de la IA al inicio.
- **Línea 121 (`Deck-AI.gd`): `tomar_carta()`**: Utilizada por el `AI-Controller` para reponer la mano de la IA.

---

## 6. Lógica de IA: `scripts/ia/AI-Controller.gd`
- **Línea 41: `choose_ai_card()`**: Algoritmo de decisión:
	1. Prioriza bloquear elementos donde el jugador tiene 2 puntos.
	2. Prioriza elementos que el jugador aún no ha ganado (para evitar victoria por "1 de cada tipo").
- **Línea 81: `play_turn()`**: Ejecuta el movimiento de la carta elegida hacia una ranura libre.

---

## 8. Estado de Bugs y Mejoras Arquitectónicas (ACTUALIZADO)

### 1. Conflicto de "Mano" vs "Ranuras KHAOS" (IA) -> **SOLUCIONADO**
- **Mejora**: Se eliminó por completo el sistema de "mano virtual" (`ManoJugador-AI.gd`). La IA ahora trata sus ranuras KHAOS (K, H, A, O, S) como su única fuente de cartas.
- **Resultado**: Las cartas ya no aparecen en posiciones aleatorias; se mantienen estrictamente dentro de las letras KHAOS hasta ser jugadas.

### 2. Fallo en la Reposición de la IA -> **SOLUCIONADO**
- **Mejora**: Se implementó `reponer_carta_en_ranura(ranura)` en `Deck-AI.gd`. 
- **Resultado**: Cuando la IA mueve una carta al centro, el mazo detecta automáticamente qué letra quedó vacía y la rellena de inmediato, manteniendo siempre 5 cartas visibles en sus carriles.

### 3. Registro Duplicado y Cartas "Zombies" -> **SOLUCIONADO**
- **Mejora**: Se simplificó `Game_Manager.gd`. El Manager ya no "crea" cartas mágicamente en el centro. Ahora simplemente limpia la ranura central tras el combate.
- **Resultado**: El `AI-Controller` es el único responsable de jugar cartas en `ranuraia`. Esto elimina los errores de "Ranura ocupada" y asegura que el flujo de cartas sea predecible.

---

## 9. Arquitectura Consolidada (Fase 2.5)

1.  **Flujo Único**: `Mazo -> Ranura KHAOS -> Ranura de Combate -> queue_free()`.
2.  **Responsabilidad Única**: 
	- `Deck-AI`: Solo instanciar y reponer.
	- `AI-Controller`: Solo decidir y mover.
	- `Game_Manager`: Solo arbitrar y limpiar.
3.  **Estándares Visuales (Fase 2.5)**:
	- **Escala Jugador**: `0.7` (Reposo) / `0.8` (Hover/Arrastre).
	- **Escala IA**: `0.8` (Estándar en KHAOS y Combate) para dar un aspecto elevado y prominente.
	- **Transiciones**: Uso mandatorio de `AnimationPlayer` con `carta_flip` para el revelado de cartas en el `Game_Manager`.
	- **Z-Index**: Cartas en `5` para estar siempre sobre las ranuras (`0`).

---

## 11. Sistema de Temporizador Visual y Juego Automático

- **`scripts/temporizador.gd`**:
	- **`iniciar_cuenta_regresiva()`**: Reproduce la animación de 20 a 0.
	- **`signal tiempo_agotado`**: Se emite al finalizar la animación (frame 20 visual, que es el final del sprite).
- **`scripts/player/Deck.gd`**:
	- **Línea 34: `_on_timer_timeout_auto_play()`**: Escucha la señal del temporizador.
	- **Línea 38: `jugar_carta_aleatoria()`**: 
		- Busca cartas disponibles en las ranuras KHAOS del jugador.
		- Elige una al azar y la mueve automáticamente a `ranuraplayer`.
		- Bloquea la carta y solicita reposición al mazo, imitando el comportamiento de un arrastre manual.
- **`scripts/ia/Game_Manager.gd`**:
	- **Línea 38: `iniciar_turno_jugador()`**: Ahora reinicia el temporizador visual al inicio de cada turno.
	- **Línea 49: `detener_turno()`**: Detiene el temporizador visual cuando el combate comienza o el turno termina.

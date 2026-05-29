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

## 8. Bugs Identificados y Conflictos de Lógica

### 1. Conflicto de "Mano" vs "Ranuras KHAOS" (IA)
- **Problema**: La IA tiene dos sistemas compitiendo por el control de las cartas.
    - El `Deck-AI.gd` reparte cartas a las ranuras físicas (`ranuraiak`, etc.).
    - El `AI-Controller.gd` y `ManoJugador-AI.gd` intentan gestionar una "mano" virtual (`cartas_en_mano`).
- **Consecuencia**: Cuando la IA "toma una carta", esta se añade a una posición flotante calculada en `ManoJugador-AI.gd` (Línea 38) en lugar de rellenar una ranura KHAOS vacía. Esto crea la ilusión de un "segundo mazo" o cartas que aparecen fuera de lugar.

### 2. Fallo en la Reposición de la IA
- **Problema**: La función `reponer_carta_en_ranura` de la IA en `Deck-AI.gd` es inconsistente.
    - `tomar_carta()` (Línea 121) añade a la mano virtual, no a una ranura específica.
    - `repartir_a_ranuras_ia()` (Línea 33) es la única que llena las ranuras KHAOS correctamente al inicio.
- **Consecuencia**: Tras un combate, las ranuras KHAOS de la IA quedan vacías permanentemente mientras las cartas nuevas se acumulan en la "mano virtual" invisible o mal posicionada.

### 3. Registro Duplicado y Cartas "Zombies"
- **Problema**: En `Game_Manager.gd`, `comparar_cartas_centrales()` (Línea 103) asigna una nueva carta directamente al estado de combate: `cartas_en_ranuras["ranuraplayer"]["ia"] = nueva_carta`.
- **Consecuencia**: Si el `AI-Controller` también intenta registrar una carta en esa misma ranura, ocurre un conflicto de estado (Logs: `⚠️ Ranura ocupada`). Además, si una carta es eliminada por `queue_free()` pero sigue en la lista `cartas_en_mano` de la IA, se producen errores de referencia nula.

---

## 9. Análisis de Debug Logs (Hallazgos)

- **`🤖 [DECK-AI] Ranuras totales en grupo 'ranuras': 12`**: Correcto (5 Jugador + 5 IA + 2 Centrales).
- **`✅ [GM] IA registró carta en ranura de combate:ranuraia`**: Se observa un registro excesivo. Esto confirma que el `Deck-AI` y el `Game_Manager` (en `comparar_cartas_centrales`) están intentando controlar el carril central simultáneamente.
- **`⚠️ [CONTROLLER] Ranura ocupada, no se puede registrar`**: Confirma que el sistema de intercambio (Swap) y el sistema de combate central están chocando al intentar escribir en la metadata de la misma ranura.
- **`🤖 [DECK-AI] Carta tomada: carta_azul9`**: Confirma que el sistema sigue usando la lógica de "mano" antigua de `ManoJugador-AI.gd` que debería estar obsoleta tras la implementación de KHAOS.

---

## 10. Funciones Obsoletas o Mal Aplicadas

1.  **`scripts/ia/ManoJugador-AI.gd`**: **OBSOLETA**. Toda su lógica de posicionamiento de mano (`actulizar_posicion_mano`) entra en conflicto con el sistema de ranuras físicas KHAOS.
2.  **`scripts/ia/ManejoCarta-AI.gd`**: **OBSOLETA**. Utiliza `AnimationPlayer` y escalas (`1.0`) que rompen la estética de los `Tweens` y la escala estándar de `0.7` definida en la Fase 2.
3.  **`AI-Controller.gd` -> `play_turn()`**: Utiliza `mano_ia.cartas_en_mano`. Debería buscar cartas directamente en las ranuras KHAOS si se quiere que la IA juegue desde sus letras.
4.  **`Game_Manager.gd` -> `comparar_cartas_centrales()`**: El bloque de código que instancia una nueva carta IA (Línea 111) duplica la responsabilidad del `Deck-AI`, causando que la IA tenga "más cartas de las que debería" o que aparezcan directamente en el centro sin pasar por su mano/ranuras.

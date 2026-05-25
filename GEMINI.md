# Mapa de Scripts - Card Wars

Este documento detalla la arquitectura, funciones clave y sistema de señales del proyecto.

## Estructura de Directorios
- `scripts/`: Núcleo y scripts globales.
- `scripts/ia/`: IA y coordinador principal.
- `scripts/player/`: Lógica del jugador e input.
- `scripts/ui/`: Interfaz.

---

## Núcleo
- **`Carta.gd`**: Controla visibilidad y señales de interacción.
    - `flip_face_up()` / `flip_face_down()`: Alterna la visibilidad del nodo `Cardimage`.
    - `_ready()`: Inicializa estado (deshabilita input si es IA, oculta si es IA).
- **`CartaRanura.gd`**: Gestiona el estado de ocupación de ranuras.
    - `_ready()`: Configura `id_ranura` y posición según `primersloot`.
- **`DB_Cartas.gd`**: Diccionario `CARTAS` que mapea nombres de archivos con atributos (ataque, tipo).
- **`fondo.gd`**: `ajustar_fondo()` escala la textura para cubrir el viewport.
- **`mesa.gd`**: `_ready()` centra la mesa en la pantalla.
- **`resultado_final.gd`**: 
    - `mostrar_resultado(ganador)`: Activa texturas de resultado (`Ganaste`, `Perdiste`, `Empate`).
- **`menu.gd`**: Controla navegación de escenas (`_on_jugar_pressed`, `_on_salir_pressed`).

## IA y Coordinación (`scripts/ia/`)
- **`Game_Manager.gd`**: **Nodo central**. 
    - `registrar_carta(ranura_id, carta, es_ia)`: Gestiona el registro de cartas y dispara `comparar_cartas` al recibir ambas.
    - `comparar_cartas(ranura_id)`: **Flujo de combate**. Revela carta IA, espera, resuelve, aplica modulaciones visuales y limpia ranuras.
    - `verificar_victoria_final()`: Evalúa condiciones de victoria según `combate.gd`.
- **`combate.gd`**:
    - `determinar_resultado(carta1, carta2)`: Lógica pura de reglas (Agua>Fuego>Planta).
    - `registrar_resultado()`: Incrementa contadores.
- **`AI-Controller.gd`**:
    - `play_turn()`: Elige carta, la registra en `GameManager`, y anima su movimiento.
- **`Deck-AI.gd`**: `tomar_carta()` gestiona el mazo, instanciación de `Carta.gd` y asignación de metadatos.

## Jugador (`scripts/player/`)
- **`Player-Controller.gd`**: Lógica de arrastre.
    - `empezar_a_arrastrar(carta)`: Cambia escala y guarda referencia.
    - `dejar_de_arrastrar()`: Verifica colisión con `CartaRanura` y registra en `GameManager`.
- **`InputManager.gd`**: Gestor de inputs de bajo nivel.
    - `raycast_al_cursor()`: Detecta colisiones (cartas o mazos).
- **`ManoJugador.gd`**: Gestiona posicionamiento de la mano (`actulizar_posicion_mano`).

## UI
- **`PuntosHUD.gd`**: `sumar_punto(quien)` activa la visibilidad de los puntos de victoria.
- **`puntos.gd`**: Similar a HUD, añade visualmente sprites de victoria en el tablero.
- **`TimerDisplay.gd`**: Muestra visualmente el tiempo restante del turno.
    - *Función*: `_process()` lee `game_manager.turn_timer.time_left` y actualiza el texto del Label en cada frame. Requiere tener asignado el nodo `Game_Manager`.

---
## Shaders y Efectos
El juego utiliza `ShaderMaterial` dinámicos aplicados por código para mejorar la estética visual.
- **`Carta.gd`**: Contiene `AURA_SHADER` (efecto eléctrico) y funciones de control.
    - `aplicar_brillo_elemental(tipo, es_oculta)`: Inicializa el aura. Si `es_oculta` es true, el aura es blanca (para la IA).
    - `revelar_color_elemental(tipo)`: Cambia el `modulate` del aura al color elemental real (tras el revelado).
    - *Funcionamiento*: El shader utiliza ondas senoidales (`sin(TIME)`) multiplicadas por el `COLOR` del nodo (`modulate`), lo que permite que el color elemental (`fuego`, `agua`, `planta`) sea vibrante y mantenga la animación eléctrica.
    - *Colores*:
        - Fuego: `#FF4D33` (Rojo suave)
        - Agua: `#3399FF` (Azul eléctrico)
        - Planta: `#4DFF4D` (Verde neón)
---
## Sistema de Interconexión
1. **Cartas -> Manejo de Cartas**: Se conectan mediante `connect_carta_signal`.
2. **Game_Manager**: Orquesta todo el combate.
3. **Turno**: El `Game_Manager` posee un `TurnTimer` (Timer nodo) que al agotarse dispara `_on_TurnTimer_timeout`.

---
## ¡Continuará!
La base del proyecto está consolidada:
- Sistema de combate con IA estratégica.
- Temporizador de turno con movimiento forzado.
- Sistema de revelado simultáneo.
- Efectos visuales de aura elemental con shaders.
El juego está listo para la siguiente fase de pulido o nuevas mecánicas.

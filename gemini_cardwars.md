# Guía de Prompts — Card Wars en Godot con Gemini 2.0 Flash (Gratis)

> Usa estos prompts directamente en la terminal con `gemini` CLI.
> Están ordenados por área de trabajo. Copia el bloque completo cada vez.

---

## Contexto base (pégalo SIEMPRE al inicio de sesiones nuevas)

```
Eres un asistente experto en Godot Engine 4 y diseño de juegos de cartas.
Estoy desarrollando "Card Wars", un remake del minijuego Card-Jitsu de Club Penguin.

REGLAS DEL JUEGO:
- 3 elementos: Fuego, Agua, Planta
- Agua vence a Fuego / Fuego vence a Planta / Planta vence a Agua
- Si mismo elemento: gana el de mayor número
- Si mismo elemento y mismo número: empate
- Victoria: ganar 3 veces con el mismo elemento, O 1 vez con cada elemento diferente

ESTADO ACTUAL:
- Hecho en Godot 4
- La IA lanza cartas al azar
- La carta de la IA es visible antes de que el jugador elija
- No hay temporizador por turno
- El tablero tiene zonas de victoria que no comunican estado visual

Responde siempre en español. Dame código GDScript listo para usar.
```

---

## Prompts por Área

### IA — Lógica con memoria de estado

```
[CONTEXTO BASE ARRIBA]

Necesito mejorar la IA del juego. Actualmente lanza cartas al azar.
Quiero que la IA tenga lógica de estado:

- Conoce qué elementos ya ganó el jugador (ej: jugador ganó Agua y Fuego, le falta Planta)
- Si al jugador le falta un elemento X para ganar, la IA prioriza cartas que venzan a X
- Si la IA misma está cerca de ganar, también prioriza completar su set
- Si ninguna condición urgente, elige aleatoriamente entre las mejores opciones

Variables disponibles:
- player_wins: Dictionary {"fuego": int, "agua": int, "planta": int}
- ai_wins: Dictionary {"fuego": int, "agua": int, "planta": int}
- ai_hand: Array de cartas, cada carta tiene .elemento (String) y .numero (int)

Devuélveme una función `choose_ai_card(player_wins, ai_wins, ai_hand) -> Card`
```

---

### Carta de IA oculta hasta que el jugador elija

```
[CONTEXTO BASE ARRIBA]

Actualmente la carta que lanza la IA es visible antes de que el jugador escoja.
Quiero que:
1. La IA elija su carta internamente pero la muestre boca abajo en el tablero
2. El jugador selecciona su carta
3. Ambas cartas se revelan simultáneamente con una pequeña animación
4. Se resuelve el combate

Tengo un nodo `CardSprite` con:
- flip_face_up() : muestra la cara de la carta
- flip_face_down() : muestra el dorso

Muéstrame cómo manejar este flujo en el GameManager.gd con señales de Godot.
```

---

### Temporizador de turno

```
[CONTEXTO BASE ARRIBA]

Quiero añadir un temporizador de 30 segundos por turno del jugador.
Requisitos:
- Un nodo Timer en escena llamado TurnTimer
- Una barra de progreso visual (ProgressBar) que se vacía en tiempo real
- Si el tiempo llega a 0, se selecciona una carta aleatoria de la mano del jugador
- El timer se reinicia al inicio de cada turno del jugador
- Se pausa si el juego está resolviendo un combate

Dame el código GDScript para el GameManager y cómo conectar las señales del Timer.
```

---

### Indicadores visuales de victoria en el tablero

```
[CONTEXTO BASE ARRIBA]

Las zonas de victoria del tablero (3 espacios por jugador) están vacías y no comunican nada.
Quiero que:
- Cuando el jugador gana con Fuego, aparezca el ícono de Fuego en su zona con un efecto de brillo
- Lo mismo para Agua y Planta
- Las victorias de la IA se muestran en su zona (parte superior del tablero)
- Usar AnimationPlayer para el efecto de aparición (scale de 0 a 1 + fade in)

Tengo nodos:
- PlayerWinsContainer: HBoxContainer con 3 TextureRect hijos (fire_slot, water_slot, plant_slot)
- AIWinsContainer: igual estructura arriba
- Texturas: fire_icon, water_icon, plant_icon (ya cargadas como variables)

Dame la función `show_win_indicator(element: String, is_player: bool)` en GDScript.
```

---

### Pantalla de resultado (victoria / derrota)

```
[CONTEXTO BASE ARRIBA]

Necesito una pantalla de resultado que aparezca al terminar la partida.
Debe mostrar:
- "¡VICTORIA!" o "DERROTA" con color apropiado
- Resumen: cuántas rondas ganó el jugador y cuántas la IA
- El elemento con el que se cerró la victoria
- Botón "Jugar de nuevo" y botón "Menú principal"

Tengo una escena ResultScreen.tscn con:
- Label result_title
- Label summary_label  
- Button play_again_btn
- Button menu_btn

Dame el script ResultScreen.gd y cómo llamarlo desde el GameManager al terminar la partida.
```

---

### Menú principal — botones con estilo temático

```
[CONTEXTO BASE ARRIBA]

El menú principal tiene botones verdes genéricos (JUGAR, OPCIONES, SALIR) que no pegan con
la paleta roja y dorada del juego de estilo oriental.

Quiero cambiar los botones a un estilo que combine con esa paleta.
En Godot 4, usando StyleBoxFlat en los botones, dame:
- Colores: normal=#8B1A1A (rojo oscuro), hover=#C9922B (dorado), presionado=#5C0000
- Bordes redondeados: 6px
- Borde exterior: 2px color dorado #C9922B
- Fuente: la que tenga disponible, tamaño 18
- Código para aplicarlo por código en el _ready() del script del menú,
  sin necesidad de editar el tema en el editor visual
```

---

### Sistema de resolución de combate (refactor limpio)

```
[CONTEXTO BASE ARRIBA]

Quiero una función de resolución de combate bien estructurada.
Entrada: dos cartas (player_card y ai_card), cada una con .elemento y .numero
Salida: "player", "ai" o "draw"

Reglas:
- Agua > Fuego > Planta > Agua
- Si mismo elemento: mayor número gana
- Si igual elemento e igual número: empate

Dame la función `resolve_combat(player_card, ai_card) -> String` en GDScript,
con un diccionario de ventajas para que sea fácil de extender si añado más elementos.
```

---

### Debug — visualizar estado del juego en pantalla

```
[CONTEXTO BASE ARRIBA]

Quiero un panel de debug que aparezca con F1 durante el juego mostrando:
- Mano actual del jugador (elemento + número de cada carta)
- Cartas en mano de la IA (cantidad, no revelar cuáles)
- Estado de victorias: player_wins y ai_wins
- Última carta jugada por cada uno

Que sea un CanvasLayer con un RichTextLabel encima de todo,
toggle con Input.is_action_just_pressed("ui_cancel") o F1.
Dame el script DebugOverlay.gd listo para añadir como Autoload o nodo hijo.
```

---

## Tips para usar Gemini en terminal

- **Sesión larga:** Pega el contexto base al inicio de cada conversación nueva, Gemini no tiene memoria entre sesiones.
- **Si el código no funciona:** Agrega al final del prompt: *"El error es: [pega el error exacto de Godot]. Corrígelo."*
- **Para iterar:** Di *"Modifica la función anterior para que además..."* sin repetir todo.
- **Pedir explicación:** Añade *"Explica línea por línea qué hace cada parte"* al final.
- **Godot 3 vs 4:** Si Gemini da código con `yield` o `export var`, dile *"Usa sintaxis Godot 4, no Godot 3"*.

---

## Orden recomendado para implementar

1. `resolve_combat` — base de todo, implementar primero
2. Carta de IA oculta — cambia la percepción del juego inmediatamente
3. IA con memoria de estado — la mejora más impactante en jugabilidad
4. Indicadores visuales de victoria — feedback visual clave
5. Temporizador de turno — añade presión
6. Pantalla de resultado — cierre limpio de partida
7. Botones temáticos del menú — polish visual
8. Debug overlay — útil durante todo el desarrollo

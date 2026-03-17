# Como funciona el juego

Este documento resume las reglas, flujo y sistemas principales de GoGoals.

## Objetivo
- Llegar a la casilla final antes que los demas jugadores.
- Responder correctamente preguntas ODS para ganar ventajas y aumentar el puntaje del ranking.

## Flujo de una partida
1. En el menu principal eliges la cantidad de jugadores.
2. Cada turno se lanza el dado y la ficha avanza la cantidad de casillas indicada.
3. Al caer en casillas especiales ocurren eventos:
   - Casilla ODS: se abre una pregunta. Si aciertas puedes continuar o ganar una ventaja.
   - Escalera: avanzas hacia una casilla superior.
   - Bajada: retrocedes hacia una casilla inferior.
4. La partida termina cuando un jugador llega a la meta.

## Controles
- `Tirar dados` lanza el dado del jugador en turno.
- `Pausa` o `ESC` abre el menu de pausa.
- En preguntas, selecciona una opcion para responder.

## Sistema de preguntas (ODS)
- Las preguntas se toman del archivo `data/questions.json`.
- Cada pregunta tiene varias opciones y una respuesta correcta.
- Al responder, el panel muestra:
  - La opcion correcta en verde y las incorrectas en rojo.
  - La explicacion (si existe) y el texto correcto.

## Ranking
- Se guardan los mejores resultados en `user://records.save`.
- El ranking ordena por:
  1. Menor cantidad de turnos.
  2. Menor tiempo total en caso de empate.

## Estructura tecnica (resumen)
- `scripts/Managers/GameManager.gd`: reglas centrales, turnos, dado y eventos.
- `scripts/Entities/*`: fichas, tablero y casillas.
- `scripts/UI/Game/*`: HUD, pausa y panel de preguntas.
- `autoloads/RecordsManager.gd`: ranking persistente.

## Notas de UI
- El HUD se separa en panel de estadisticas y panel de dado.
- El panel de ranking usa un layout con filas personalizadas y scroll.


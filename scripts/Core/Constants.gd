extends Node
class_name Constants

# ============================================
# CONSTANTES DEL JUEGO - GoGoals
# ============================================

# --- RUTAS DE ESCENAS ---
const SCENE_MENU_PRINCIPAL := "res://ui/MenuPrincipal.tscn"
const SCENE_PANTALLA_JUEGO := "res://scenes/pantalla_de_juego.tscn"
const SCENE_END_GAME := "res://ui/EndGameMenu.tscn"
const SCENE_COMO_JUGAR := "res://ui/ComoJugar.tscn"

# --- RUTAS DE RECURSOS ---
const QUESTIONS_FILE := "res://data/questions.json"
const SETTINGS_FILE := "user://settings.save"

# --- CONFIGURACIÓN DE JUEGO ---
const MIN_PLAYERS := 1
const MAX_PLAYERS := 4
const DICE_MIN := 1
const DICE_MAX := 6

# --- CONFIGURACIÓN DE TIEMPO ---
const DEFAULT_GAME_TIME := 0.0

# --- CONFIGURACIÓN DE GRÁFICOS ---
const PLAYER_SCALE_DEFAULT := Vector2(0.8, 0.8)
const PLAYER_OFFSET_X := 10
const PLAYER_OFFSET_Y := 5

# --- CONFIGURACIÓN DE ANIMACIONES ---
const MOVEMENT_TWEEN_DURATION := 0.3
const SPECIAL_MOVE_TWEEN_DURATION := 0.5

# --- CONFIGURACIÓN DE AUDIO ---
const MUSIC_VOLUME_DEFAULT := -10.0
const SFX_VOLUME_DEFAULT := 0.0
const MUSIC_VOLUME_MIN := -24.0
const MUSIC_VOLUME_MAX := 0.0
const SFX_VOLUME_MIN := -24.0
const SFX_VOLUME_MAX := 0.0
const SFX_STEP_VOLUME_MOD := -5.0

# --- CONFIGURACIÓN DE RÉCORDS ---
const MAX_RECORDS := 10
const RECORDS_FILE := "user://records.save"

# --- CONFIGURACIÓN DE UI ---
const TIME_FORMAT := "%02d:%05.2f"

# --- MENSAJES DE JUEGO ---
const MSG_VICTORY := "¡JUGADOR %d GANA!"
const MSG_CORRECT := "¡Correcto! J%d tira otra vez."
const MSG_INCORRECT := "Incorrecto."
const MSG_DICE_ROLL := "J%d sacó: %d"
const MSG_TURN := "Turno: Jugador %d (Tirada #%d)"
const MSG_TIME := "Tiempo: %s"

# --- TIPO DE CASILLAS ---
enum TileType {
	NORMAL,
	QUIZ,
	SPECIAL_LADDER,  # Escalera - sube
	SPECIAL_SLIDE,   # Deslizador - baja
	START,
	FINISH
}

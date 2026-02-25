extends Sprite2D # <--- IMPORTANTE: Ahora extiende de Sprite2D

# --- CONFIGURACIÓN ---
@export_group("Movimiento")
@export var speed : float = 2.0        # Velocidad de la animación
@export var float_range : float = 10.0 # Cuántos píxeles sube y baja

@export_group("Rotación")
@export var rotate_speed : float = 1.5 # Velocidad de balanceo
@export var rotate_range : float = 5.0 # Grados de inclinación

# Variables internas
var time = 0.0
var initial_y = 0.0
var random_offset = 0.0

func _ready():
	# Guardamos la altura inicial donde pusiste el sprite en el editor
	initial_y = position.y
	
	# Generamos un desfase aleatorio para que no se muevan todos igual
	random_offset = randf_range(0.0, 10.0)

func _process(delta):
	time += delta
	
	# 1. Flotar (Seno)
	var float_offset = sin((time + random_offset) * speed) * float_range
	position.y = initial_y + float_offset
	
	# 2. Rotar (Coseno) - Balanceo suave
	var rot_offset = cos((time + random_offset) * rotate_speed) * rotate_range
	rotation_degrees = rot_offset

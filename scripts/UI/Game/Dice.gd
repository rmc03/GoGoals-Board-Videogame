extends Control
class_name DiceUI

# ============================================
# COMPONENTE UI - DADOS
# Visualización y control de los dados
# ============================================

# --- REFERENCIAS ---
@export var dice_button: Button
@export var dice_label: Label

# --- CONFIGURACIÓN ---
var is_enabled: bool = true

# --- SEÑALES ---
signal dice_rolled(value: int)

func _ready() -> void:
	if dice_button:
		dice_button.pressed.connect(_on_dice_pressed)

func _on_dice_pressed() -> void:
	if is_enabled:
		# Animación de dado (placeholder)
		_animate_roll()
		dice_rolled.emit(randi_range(1, 6))

func _animate_roll() -> void:
	# Animación visual del dado
	if dice_label:
		var tween = create_tween()
		for i in range(5):
			tween.tween_property(dice_label, "rotation", randf_range(-0.2, 0.2), 0.05)
		tween.tween_property(dice_label, "rotation", 0.0, 0.05)

func set_dice_value(value: int) -> void:
	if dice_label:
		dice_label.text = str(value)

func set_enabled(enabled: bool) -> void:
	is_enabled = enabled
	if dice_button:
		dice_button.disabled = not enabled

func show_result(value: int) -> void:
	set_dice_value(value)

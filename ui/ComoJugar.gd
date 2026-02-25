extends Control

@onready var btn_volver: Button = $BotonVolver

func _ready() -> void:
	btn_volver.pressed.connect(_on_volver_pressed)

func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/MenuPrincipal.tscn")

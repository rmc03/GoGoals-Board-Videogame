extends Control

@onready var btn_volver = $BotonVolver

func _ready():
	btn_volver.pressed.connect(_on_volver_pressed)

func _on_volver_pressed():
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")
	

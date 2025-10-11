extends Control

@onready var NextScene = preload("res://Menus/scenes/main_menu.tscn")

func _ready():
	pass

func _on_button_pressed() -> void:
	ChangeScene()

func ChangeScene():
	get_tree().change_scene_to_packed(NextScene)

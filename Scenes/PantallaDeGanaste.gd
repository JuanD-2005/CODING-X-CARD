extends Control

@onready var Scene = preload("res://Menus/scenes/main_menu.tscn")
@onready var NextScene = preload("res://Menus/scenes/Introduccion.tscn")
@onready var AnimatedFrames = $AnimatedSprite2D

func _ready():
	AnimatedFrames.play("default")

func _on_button_pressed():
	ChangeScene()

func ChangeScene():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().change_scene_to_packed(NextScene)

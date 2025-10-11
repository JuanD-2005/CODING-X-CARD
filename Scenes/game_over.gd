extends Control

@onready var Scene = preload("res://Menus/scenes/main_menu.tscn")
@onready var AnimatedFrames = $AnimatedSprite2D

func _ready():
	AnimatedFrames.play("default")

func _on_button_pressed():
	ChangeScene()

func ChangeScene():
	get_tree().change_scene_to_packed(Scene)

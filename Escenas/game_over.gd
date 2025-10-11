extends Control

@onready var dialogue_label = $Label
var full_text = "No debiste venir aquí..."
var current_text = ""
var index = 0

func _ready():
	$Button.pressed.connect(_on_restart_pressed)  # Conectar el botón
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Hace visible el cursor
	$Timer.wait_time = 0.1  # Establece el intervalo de tiempo entre caracteres
	$Timer.start()  # Temporizador que mostrará el texto poco a poco

func _on_Timer_timeout():
	if index < full_text.length():
		current_text += full_text[index]
		dialogue_label.text = current_text
		index += 1
	else:
		$Timer.stop()

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://Menus/scenes/main_menu.tscn")  # Cambia a la escena del juego
	$Timer.start()  # Temporizador que mostrará el texto poco a poco

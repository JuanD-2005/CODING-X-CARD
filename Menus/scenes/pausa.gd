extends Node

@onready var NextScene = preload("res://Menus/scenes/main_menu.tscn")

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS  # Permite entrada aunque el juego esté pausado

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pausa"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = not get_tree().paused
	print("Pausa: ", get_tree().paused)
	$Control.visible = get_tree().paused  # Muestra/oculta el menú
	
	# Manejo del mouse
	if get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # Muestra el cursor
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  # Oculta y bloquea el cursor (útil para FPS)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(NextScene)

extends StaticBody3D

@onready var CardGame: PackedScene = preload("res://Scenes/table_2.tscn")

# 1. Cargamos la imagen de la captura desde tus archivos (Cambia esta ruta por la real)
const TEXTURA_TRANSICION = preload("res://Extras/CAPTURE2.jpg")

signal NPcsNumber(Variable)
var NPCs = 3

func interact():
	# 2. Buscamos el nodo en tu UI usando tu ruta exacta
	var telon = $"../../UI/imagen_transicion"
	
	if telon:
		# 3. ¡AQUÍ SE PONE LA TEXTURA! Asignamos la imagen cargada al nodo
		telon.texture = TEXTURA_TRANSICION
		
		# Aseguramos que empiece invisible y se muestre
		telon.modulate.a = 0.0
		telon.show()
		
		# Iniciamos el desvanecimiento hacia negro/imagen
		var tween = create_tween()
		tween.tween_property(telon, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		
		# Esperamos a que la pantalla se tape por completo
		await tween.finished
	else:
		print("Error: No se encontró el nodo en la ruta ../../UI/imagen_transicion")

	# Nos vamos a la escena de las cartas
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  
	get_tree().change_scene_to_packed(CardGame)

func _process(delta: float) -> void:
	pass

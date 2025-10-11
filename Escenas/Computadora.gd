extends StaticBody3D
@onready var CardGame: PackedScene = preload("res://Scenes/table_2.tscn")

signal NPcsNumber(Variable)

var NPCs = 3

func _ready() -> void:
	pass # Replace with function body.

func interact():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # Muestra el cursor
	get_tree().change_scene_to_packed(CardGame)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Control

@onready var option_menu: TabContainer = $"../Options"

func _ready():
	$VBoxContainer/Start.grab_focus()

func reset_focus():
	$VBoxContainer/Start.grab_focus()

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/table.tscn")
	

func _on_option_pressed():
	option_menu.show()



func _on_quit_pressed():
	get_tree().quit()


func _on_back_pressed():
	option_menu.hide()
	
func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0,value)


func _on_button_pressed_Exit() -> void:
	option_menu.hide()

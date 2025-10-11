extends TabBar

@onready var master: HSlider = $HBoxContainer/VBoxContainer2/Master
@onready var music: HSlider = $HBoxContainer/VBoxContainer2/Music
@onready var sound_effect: HSlider = $HBoxContainer/VBoxContainer2/SoundEffects



func _on_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0,value)
	
	

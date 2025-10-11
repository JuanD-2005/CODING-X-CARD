extends Area3D
@onready var transition_rect = $"../../Transicion/ColorRect"


	
func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		transition_rect.visible = true  # Hacer visible el ColorRect
		transition(true)
		await get_tree().create_timer(0.5).timeout  # Espera el efecto
		get_tree().change_scene_to_file("res://Escenas/FINAL.tscn")
		# No necesitamos transition(false) aquí, ya que la escena se reemplaza
		# y el ColorRect desaparecerá con la nueva escena.

func transition(fade_in: bool) -> void:
	var tween = create_tween()
	if fade_in:
		tween.tween_property(transition_rect.material, "shader_parameter/height", 1.0, 0.5) # Pantalla llena
	else:
		tween.tween_property(transition_rect.material, "shader_parameter/height", -1.0, 0.5) # Transparente

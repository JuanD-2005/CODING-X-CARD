extends Area3D
@onready var transition_rect = $"../../../Transicion/ColorRect"

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		transition_rect.visible = true  # Hacer visible el ColorRect
		transition(true)
		await get_tree().create_timer(0.5).timeout  # Espera el efecto
		body.set_global_position(Vector3(-11.54467, 4.67585, 106.2402))
		transition(false)
		await get_tree().create_timer(0.5).timeout  # Espera el desvanecimiento
		

func transition(fade_in: bool) -> void:
	var tween = create_tween()
	if fade_in:
		tween.tween_property(transition_rect.material, "shader_parameter/height", 1.0, 0.5) # Pantalla llena
	else:
		tween.tween_property(transition_rect.material, "shader_parameter/height", -1.0, 0.5) # Transparente

extends Area3D
@onready var hit_rect = $"../UI/HitRect"
var tween: Tween


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		tween = get_tree().create_tween()
		hit_rect.visible = true
		tween.tween_property($"../Player/Head/Camera3D", "fov", 120, 0.3)  # Hace zoom en 1 segundo
		await tween.finished
		get_tree().change_scene_to_file("res://Escenas/Game_Over.tscn")
		hit_rect.visible = false 

extends Area3D



func LAVA_entered(body: Node3D) -> void:
	$"../Lava_movible/AnimationPlayer".play("Movimiento")

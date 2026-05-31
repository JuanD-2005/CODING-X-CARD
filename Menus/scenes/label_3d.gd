extends Label3D

func _ready():
	# Creamos el animador por código
	var tween = create_tween()
	
	# Le decimos que haga todas las animaciones AL MISMO TIEMPO
	tween.set_parallel(true) 
	
	# 1. Efecto "Pop" al aparecer (Empieza en tamaño 0 y crece a tamaño 1 con rebote)
	scale = Vector3.ZERO
	tween.tween_property(self, "scale", Vector3.ONE, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	
	# 2. Flotar hacia arriba (Sube 1.5 metros desde su posición actual)
	tween.tween_property(self, "position:y", position.y + 1.5, 1.0).set_ease(Tween.EASE_OUT)
	
	# 3. Desvanecerse (El canal 'a' es el Alpha/Transparencia. Lo pasamos a 0)
	tween.tween_property(self, "modulate:a", 0.0, 1.0).set_ease(Tween.EASE_IN)
	
	# 4. Cuando todas las animaciones paralelas terminen, destruimos el nodo
	tween.chain().tween_callback(queue_free)

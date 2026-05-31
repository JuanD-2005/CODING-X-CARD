extends Node3D

@onready var muro_negro: MeshInstance3D = $Player/Head/Camera3D/MeshInstance3D
@onready var jugador: Node3D = $Player
const TEXTO_FLOTANTE = preload("res://Extras/Texto_Flotante.tscn")

func _ready() -> void:
	if muro_negro:
		print("¡Muro físico detectado! Iniciando demolición controlada...")
		var tween = create_tween()
		
		# Animamos la propiedad 'transparency' del nodo (0.0 a 1.0)
		tween.tween_property(muro_negro, "transparency", 1.0, 1.5).set_ease(Tween.EASE_IN_OUT)
		
		# Destruimos el muro y llamamos al texto
		tween.tween_callback(muro_negro.queue_free)
		tween.tween_callback(arrancar_fase_accion)
	else:
		print("ERROR: No se encontró el muro físico.")
		arrancar_fase_accion()

func arrancar_fase_accion() -> void:
	var texto_inicio = TEXTO_FLOTANTE.instantiate()
	add_child(texto_inicio)

	var label = texto_inicio.get_node_or_null("Label3D")
	if label:
		label.text = "!FASE DE ACCION!"

	if jugador:
		texto_inicio.global_position = jugador.global_position + Vector3(0, 2.5, 0)

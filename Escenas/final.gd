extends Node3D

# --- REFERENCIAS DIRECTAS AL NUEVO ÁRBOL ---
@onready var hit_rect: ColorRect = $UI/HitRect
# ¡Ruta actualizada! Ahora Telon vive dentro de UI
@onready var telon_negro: ColorRect = $UI/Telon 
@onready var jugador: Node3D = $Player

# Recuerda crear este Label dentro de UI para los números
@onready var timer_label: Label = get_node_or_null("UI/TimerLabel")

# --- EL RELOJ INVERSO ---
var tiempo_negativo: float = 0.0
var el_reloj_corre: bool = false

func _ready() -> void:
	if hit_rect:
		hit_rect.visible = false

	# Arranque del telón
	if telon_negro:
		# Como volvimos a ColorRect, animamos color:a
		telon_negro.color.a = 1.0
		telon_negro.show()

		var tween = create_tween()
		tween.tween_property(telon_negro, "color:a", 0.0, 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_callback(arrancar_fase_accion)

func arrancar_fase_accion() -> void:
	if telon_negro:
		telon_negro.hide()
	
	# El reloj empieza a correr hacia la condena
	el_reloj_corre = true

func _process(delta: float) -> void:
	if el_reloj_corre:
		# Va para atrás: restamos delta 
		tiempo_negativo -= delta
		
		# Valor absoluto para desarmar el tiempo sin romper las matemáticas
		var tiempo_absoluto = abs(tiempo_negativo)
		
		var milisegundos = int(fmod(tiempo_absoluto, 1.0) * 100)
		var segundos = int(tiempo_absoluto) % 60
		var minutos = int(tiempo_absoluto) / 60
		
		if timer_label:
			# Forzamos el signo negativo al principio
			timer_label.text = "-%02d:%02d:%02d" % [minutos, segundos, milisegundos]
			timer_label.modulate = Color.RED

# --- SISTEMA DE DAÑO (CON PENALIZACIÓN) ---
func _on_player_player_hit() -> void:
	if hit_rect:
		hit_rect.visible = true
		
		# El daño te hunde 5 segundos más en el negativo
		tiempo_negativo -= 5.0
		
		if timer_label:
			var tween = create_tween()
			tween.tween_property(timer_label, "scale", Vector2(1.4, 1.4), 0.05)
			tween.tween_property(timer_label, "scale", Vector2(1.0, 1.0), 0.05)
			
		await get_tree().create_timer(0.2).timeout
		hit_rect.visible = false

extends Node3D

# --- REFERENCIAS DIRECTAS ---
@onready var hit_rect: ColorRect = $UI/HitRect
@onready var telon_negro: TextureRect = $CanvasLayer/Telon
@onready var jugador: Node3D = $Player

# --- LA MACRO IDEA: EL RELOJ ---
@onready var timer_label: Label = $UI/TimerLabel
var tiempo_restante: float = 55.0 # ¡Ajusta los segundos a lo que tarde el laberinto!
var el_reloj_corre: bool = false

func _ready() -> void:
	if hit_rect:
		hit_rect.visible = false

	if telon_negro:
		telon_negro.modulate.a = 1.0 
		telon_negro.show()

		var tween = create_tween()
		tween.tween_property(telon_negro, "modulate:a", 0.0, 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_callback(arrancar_fase_accion)

func arrancar_fase_accion() -> void:
	if telon_negro:
		telon_negro.hide()
	
	# ¡El reloj arranca EXACTAMENTE cuando el telón desaparece!
	el_reloj_corre = true

# --- LA CUENTA ATRÁS ---
func _process(delta: float) -> void:
	if el_reloj_corre and tiempo_restante > 0:
		# Restamos el tiempo
		tiempo_restante -= delta
		
		# Calculamos el formato visual
		var milisegundos = int(fmod(tiempo_restante, 1.0) * 100)
		var segundos = int(tiempo_restante) % 60
		var minutos = int(tiempo_restante) / 60
		
		if timer_label:
			# Actualizamos el texto en formato 00:00:00
			timer_label.text = "%02d:%02d:%02d" % [minutos, segundos, milisegundos]
		
			# ¡ALERTA! Menos de 10 segundos
			if tiempo_restante <= 10.0:
				timer_label.modulate = Color.RED
			else:
				timer_label.modulate = Color.WHITE
		
		# GAME OVER POR TIEMPO
		if tiempo_restante <= 0:
			el_reloj_corre = false
			timer_label.text = "00:00:00"
			# Reinicia el nivel bruscamente (Castigo)
			get_tree().reload_current_scene()

# --- SISTEMA DE DAÑO (CON PENALIZACIÓN DE TIEMPO) ---
func _on_player_player_hit() -> void:
	if hit_rect:
		hit_rect.visible = true
		
		# ¡PENALIZACIÓN! Recibir daño quita 5 segundos del reloj
		tiempo_restante -= 5.0 
		
		# Feedback visual para el jugador: el reloj parpadea
		if timer_label:
			var tween = create_tween()
			tween.tween_property(timer_label, "scale", Vector2(1.5, 1.5), 0.1)
			tween.tween_property(timer_label, "scale", Vector2(1.0, 1.0), 0.1)
			
		await get_tree().create_timer(0.2).timeout
		hit_rect.visible = false

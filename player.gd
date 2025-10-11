class_name Player
extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.007
const WALL_JUMP_FORCE = 7.0 # Fuerza del salto en la pared
const WALL_SLIDE_GRAVITY = 1.0 # Gravedad reducida al deslizarse por la pared
const HIT_STAGGER = 8.0
signal player_hit

#bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.07
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

@onready var head = $Head
@onready var camera = $Head/Camera3D

@onready var hand_left = $Head/Sprite3D2 # Asumiendo que Sprite3D2 es la mano izquierda
@onready var hand_right = $Head/Sprite3D # Asumiendo que Sprite3D es la mano derecha
@onready var raycast = $Head/Camera3D/RayCast3D
var collider = null 

# Variables para la animación de las manos
const HAND_SWAY_FREQ = 2.5 # Frecuencia del movimiento de las manos
const HAND_SWAY_AMP = 0.1 # Amplitud del movimiento de las manos
var t_hand_sway = 0.0
var initial_left_y = 0.0
var initial_right_y = 0.0

const CROUCH_SPEED = 2.5
const CROUCH_HEIGHT = 0.5
const NORMAL_HEIGHT = 1.0

var is_crouching = false



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	initial_left_y = hand_left.position.y
	initial_right_y = hand_right.position.y
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-10), deg_to_rad(68))
	if Input.is_action_just_pressed("agacharse"):
		_toggle_crouch()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if is_on_wall_only():
			velocity += get_gravity() * delta * WALL_SLIDE_GRAVITY # reduce gravity on wall
		else:
			velocity += get_gravity() * delta

	if raycast.is_colliding():
		collider = raycast.get_collider()
		if collider != null:
			if Input.is_action_just_pressed("accion"):
				if collider.has_method("interact"):
					collider.interact()
					
	else:
		collider = null
	# Handle jump.
	if Input.is_action_just_pressed("salto"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif is_on_wall_only():
			var normal: Vector3 = get_last_slide_collision().get_normal()
			velocity.y = JUMP_VELOCITY  # o simplemente JUMP_VELOCITY
			velocity += normal * WALL_JUMP_FORCE

	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
	
	 # Animación de las manos
	t_hand_sway += delta * velocity.length() * float(is_on_floor())
	_animate_hands(t_hand_sway)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()

func _animate_hands(time):
	var sway_offset = sin(time * HAND_SWAY_FREQ) * HAND_SWAY_AMP

	# Mueve la mano izquierda hacia arriba y abajo, usando la posición inicial como base
	hand_left.position.y = initial_left_y + sway_offset

	# Mueve la mano derecha en la dirección opuesta, usando la posición inicial como base
	hand_right.position.y = initial_right_y - sway_offset

	# Ajusta la rotación si quieres un efecto más pronunciado
	# hand_left.rotation_degrees.x = sway_offset * 20 # Ejemplo de rotación
	# hand_right.rotation_degrees.x = -sway_offset * 20 # Ejemplo de rotación

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func hit(dir):
	emit_signal("player_hit")
	velocity += dir * HIT_STAGGER
	await get_tree().create_timer(0.5).timeout 
	game_over() # Llamar a la función de Game Over

func game_over():
	get_tree().change_scene_to_file("res://Escenas/Game_Over.tscn") # Cambia a la escena de Game Over

func _toggle_crouch():
	if is_crouching:
		# Volver a la altura normal
		$CollisionShape3D.scale.y = NORMAL_HEIGHT
		camera.position.y += (NORMAL_HEIGHT - CROUCH_HEIGHT) # Ajuste de la cámara
		speed = WALK_SPEED # Restaurar velocidad normal
	else:
		# Agacharse
		$CollisionShape3D.scale.y = CROUCH_HEIGHT
		camera.position.y -= (NORMAL_HEIGHT - CROUCH_HEIGHT) # Ajuste de la cámara
		speed = CROUCH_SPEED # Reducir velocidad al agacharse

	is_crouching = !is_crouching

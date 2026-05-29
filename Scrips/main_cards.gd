class_name MainCards extends Node2D

# ------------------------------------------------------------------
# Señales
# ------------------------------------------------------------------
signal mouse_entered(card: MainCards)
signal mouse_exited(card: MainCards)

# ------------------------------------------------------------------
# Propiedades de la carta (exportadas para poder ajustar desde fuera)
# ------------------------------------------------------------------
@export var figure: String = ""          # "Cuadrado", "Equis", "Triangulo", "Circulo", "ERROR"
@export var number: String = ""          # "I", "II", ..., "XII", "ERROR"
@export var is_reverse: bool = false
@export var is_skip: bool = false        # Antes Cancel
@export var is_draw2: bool = false       # Antes Adder
@export var is_wild: bool = false        # Antes Change
@export var color_texture: Texture       # Textura actual de la carta

# Parámetros de generación aleatoria
@export var max_number: int = 13         # 0-12 (0: sin número, 1-9 normales, 10 reverse, 11 skip, 12 +2)
@export var max_color: int = 56          # Rango para seleccionar color/comodín

# Estado de la carta
var original_z_index: int
var card_position: Vector2
var card_rotation: float
var is_following: bool = false
var is_valid: bool = false               # Si es válida para descartar
var click_to_remove: bool = false        # Usado por la mano al arrastrar
var revealed: bool = true                # Si está boca arriba

# Referencias a nodos hijos
@onready var number_label: Label = $CardSprite/NumberLbl
@onready var card_sprite: Sprite2D = $CardSprite
@onready var card_area: Area2D = $CardSprite/Area2D

# ------------------------------------------------------------------
# Diccionarios de texturas (evitan múltiples load())
# ------------------------------------------------------------------
const COLOR_TEXTURES = {
	"Cuadrado": {
		"default": "res://Sprites/Cuadrado.png",
		"reverse": "res://Sprites/Cuadrado Reverse.png",
		"skip": "res://Sprites/Cuadrado Cancel.png",
		"draw2": "res://Sprites/Cuadrado Sumador.png",
	},
	"Equis": {
		"default": "res://Sprites/Equis.png",
		"reverse": "res://Sprites/Equis Reverse.png",
		"skip": "res://Sprites/Equis Cancel.png",
		"draw2": "res://Sprites/Equis Sumador.png",
	},
	"Triangulo": {
		"default": "res://Sprites/Triangulo.png",
		"reverse": "res://Sprites/Triangulo Reverse.png",
		"skip": "res://Sprites/Triangulo Cancel.png",
		"draw2": "res://Sprites/Triangulo Sumador.png",
	},
	"Circulo": {
		"default": "res://Sprites/Circulo.png",
		"reverse": "res://Sprites/Circulo Reverse.png",
		"skip": "res://Sprites/Circulo Cancel.png",
		"draw2": "res://Sprites/Circulo Sumador.png",
	},
}

const WILD_TEXTURES = {
	"Cuadrado": "res://Sprites/Rosa.png",
	"Equis": "res://Sprites/Azul.png",
	"Triangulo": "res://Sprites/Verde.png",
	"Circulo": "res://Sprites/Rojo.png",
}

const BACK_TEXTURE = "res://Sprites/Default.png"
const WILD_DEFAULT_TEXTURE = "res://Sprites/3RR05.png"

# ------------------------------------------------------------------
# Inicialización
# ------------------------------------------------------------------
func _ready():
	original_z_index = card_sprite.z_index
	generate_random_card()
	apply_texture()
	update_label()

# ------------------------------------------------------------------
# Generación aleatoria de la carta
# ------------------------------------------------------------------
func generate_random_card():
	var rand_number = randi() % max_number
	var rand_color = randi() % max_color + 1

	# Determinar figura o comodín
	if rand_color >= 52:
		figure = "ERROR"
		number = "ERROR"
		is_wild = true
	else:
		var color_index = int(rand_color / 13)  # 0-3
		var colors = ["Cuadrado", "Equis", "Triangulo", "Circulo"]
		figure = colors[color_index]

		# Asignar número o efecto especial
		match rand_number:
			0:  number = ""
			1:  number = "I"
			2:  number = "II"
			3:  number = "III"
			4:  number = "IV"
			5:  number = "V"
			6:  number = "VI"
			7:  number = "VII"
			8:  number = "VIII"
			9:  number = "IX"
			10:
				is_reverse = true
				number = "X"
			11:
				is_skip = true
				number = "XI"
			12:
				is_draw2 = true
				number = "XII"

# ------------------------------------------------------------------
# Aplicar la textura según las propiedades actuales
# ------------------------------------------------------------------
func apply_texture():
	if not revealed:
		color_texture = load(BACK_TEXTURE)
		card_sprite.texture = color_texture
		return

	if is_wild:
		# Comodín: si ya tiene figura asignada (tras elegir color), usar textura de color
		if figure in WILD_TEXTURES:
			color_texture = load(WILD_TEXTURES[figure])
		else:
			color_texture = load(WILD_DEFAULT_TEXTURE)
		card_sprite.texture = color_texture
		return

	# Cartas normales o especiales
	if figure in COLOR_TEXTURES:
		var textures = COLOR_TEXTURES[figure]
		var texture_path: String
		if is_reverse:
			texture_path = textures["reverse"]
		elif is_skip:
			texture_path = textures["skip"]
		elif is_draw2:
			texture_path = textures["draw2"]
		else:
			texture_path = textures["default"]
		color_texture = load(texture_path)
	else:
		color_texture = load(BACK_TEXTURE)  # Fallback

	card_sprite.texture = color_texture

# ------------------------------------------------------------------
# Actualizar etiqueta con el número (si corresponde)
# ------------------------------------------------------------------
func update_label():
	if revealed and not is_reverse and not is_skip and not is_draw2 and not is_wild:
		number_label.text = number
	else:
		number_label.text = ""  # Las cartas especiales no muestran número

# ------------------------------------------------------------------
# Revelar la carta (cuando un NPC la descarta, por ejemplo)
# ------------------------------------------------------------------
func reveal_card():
	revealed = true
	apply_texture()
	update_label()

# ------------------------------------------------------------------
# Control visual al seguir el ratón o volver a la mano
# ------------------------------------------------------------------
func _process(_delta):
	if is_following:
		position = get_global_mouse_position()

func highlight():
	card_sprite.z_index = 100

func unhighlight():
	card_sprite.z_index = original_z_index

# ------------------------------------------------------------------
# Señales de entrada del mouse (para la mano del jugador)
# ------------------------------------------------------------------
func _on_area_2d_mouse_entered():
	mouse_entered.emit(self)

func _on_area_2d_mouse_exited():
	mouse_exited.emit(self)

# ------------------------------------------------------------------
# Método para iniciar/detener el arrastre de la carta
# ------------------------------------------------------------------
func follow():
	if not is_following:
		# Guardar posición y rotación originales, empezar a seguir
		card_position = position
		card_rotation = rotation
		rotation = 0
		is_following = true
	else:
		# Soltar carta: si es válida se queda en la pila, si no vuelve a la mano
		if is_valid:
			position = Vector2(496, 315)  # Posición de descarte
		else:
			position = card_position
			rotation = card_rotation
			click_to_remove = false
		is_following = false

# ------------------------------------------------------------------
# Cambiar la carta de padre (útil para moverla entre mano y mesa)
# ------------------------------------------------------------------
func change_parent(new_parent: Node):
	if new_parent == null:
		return
	var old_parent = get_parent()
	if old_parent:
		old_parent.remove_child(self)
	new_parent.add_child(self)

func move_original_parent(original_parent: Node2D):
	if original_parent == null:
		return
	var current_parent = get_parent()
	if current_parent:
		current_parent.remove_child(self)
	original_parent.add_child(self)

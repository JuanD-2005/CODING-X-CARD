@tool
class_name Hand extends Node2D

# ------------------------------------------------------------------
# Señales
# ------------------------------------------------------------------
signal card_discarded(card: Node2D)

# ------------------------------------------------------------------
# Parámetros de exportación
# ------------------------------------------------------------------
@export var hand_radius: float = 1000.0
@export var base_angle: float = 90.0
@export var max_angle_between_cards: float = 15.0
@export var min_angle_between_cards: float = 3.0
@export var is_npc: bool = false

# ------------------------------------------------------------------
# Referencias a nodos hijos
# ------------------------------------------------------------------
@onready var card_preview = $MainCards
@onready var collision_shape_node: CollisionShape2D = $Area2D/CardCollision

# ------------------------------------------------------------------
# Estado de la mano
# ------------------------------------------------------------------
var cards: Array = []
var hovered_cards: Array = []
var selected_card_index: int = -1
var is_card_dragged: bool = false
var current_dragged_card: Node2D = null

var is_my_turn: bool = false
var can_play: bool = true
var discard_color: String = ""
var discard_number: String = ""
var has_discarded: bool = false
var winner: bool = false

# Nueva: referencia al indicador luminoso del NPC (asignado por la mesa)
var npc_indicator: Sprite2D = null

# ------------------------------------------------------------------
# Inicialización
# ------------------------------------------------------------------
func _ready():
	_update_collision_radius()
	if is_npc and card_preview:
		card_preview.visible = false

# ------------------------------------------------------------------
# Gestión de cartas
# ------------------------------------------------------------------
func add_card(card: Node2D) -> void:
	"""Añade una carta a la mano y la posiciona."""
	if is_npc:
		card.revealed = false
	cards.append(card)
	add_child(card)
	if not is_npc:
		card.mouse_entered.connect(_on_card_mouse_entered)
		card.mouse_exited.connect(_on_card_mouse_exited)
	reposition_cards()

func remove_card(index: int) -> Node2D:
	var card = cards[index]
	cards.remove_at(index)
	if hovered_cards.has(card):
		hovered_cards.erase(card)
	if not is_npc and card.has_signal("mouse_entered"):
		card.mouse_entered.disconnect(_on_card_mouse_entered)
		card.mouse_exited.disconnect(_on_card_mouse_exited)
	reposition_cards()
	return card

# ------------------------------------------------------------------
# Devuelve la posición local donde aparecería la siguiente carta
# ------------------------------------------------------------------
func get_new_card_position() -> Vector2:
	var new_count = cards.size() + 1
	var angle_step = clamp(max_angle_between_cards / new_count, min_angle_between_cards, max_angle_between_cards)
	var start_angle = - (angle_step * (new_count - 1)) / 2.0 - base_angle
	var angle = start_angle + cards.size() * angle_step
	return _get_card_position(angle)

# ------------------------------------------------------------------
# Reposiciona las cartas existentes
# ------------------------------------------------------------------
func reposition_cards() -> void:
	if cards.is_empty():
		return
	var angle_step = clamp(max_angle_between_cards / cards.size(), min_angle_between_cards, max_angle_between_cards)
	var start_angle = - (angle_step * (cards.size() - 1)) / 2.0 - base_angle
	for i in range(cards.size()):
		var angle = start_angle + i * angle_step
		_update_card_transform(cards[i], angle)

func _get_card_position(angle_deg: float) -> Vector2:
	var rad = deg_to_rad(angle_deg)
	return Vector2(hand_radius * cos(rad), hand_radius * sin(rad))

func _update_card_transform(card: Node2D, angle_deg: float) -> void:
	card.position = _get_card_position(angle_deg)
	card.rotation = deg_to_rad(angle_deg + 90.0)

# ------------------------------------------------------------------
# Interacción del jugador
# ------------------------------------------------------------------
func _on_card_mouse_entered(card: Node2D) -> void:
	if not hovered_cards.has(card):
		hovered_cards.append(card)

func _on_card_mouse_exited(card: Node2D) -> void:
	hovered_cards.erase(card)

func _input(event: InputEvent) -> void:
	if not is_my_turn or is_npc:
		return
	if event.is_action_pressed("Mouse_click") and selected_card_index >= 0:
		if is_card_dragged:
			var card = current_dragged_card
			card.follow()
			if can_play:
				var idx = cards.find(card)
				if idx != -1:
					remove_card(idx)
				card_discarded.emit(card)
			else:
				card.move_original_parent(self)
			is_card_dragged = false
			current_dragged_card = null
		else:
			current_dragged_card = cards[selected_card_index]
			current_dragged_card.click_to_remove = false
			current_dragged_card.change_parent(get_parent())
			current_dragged_card.follow()
			is_card_dragged = true
		selected_card_index = -1
		can_play = false

func _process(_delta: float) -> void:
	_update_hover_and_selection()
	_update_collision_radius()
	_update_preview_card()

func _update_hover_and_selection() -> void:
	selected_card_index = -1
	for card in cards:
		card.unhighlight()
	if not is_npc and hovered_cards.size() > 0:
		var highest_index = -1
		for card in hovered_cards:
			var idx = cards.find(card)
			if idx > highest_index:
				highest_index = idx
		if highest_index >= 0 and highest_index < cards.size():
			cards[highest_index].highlight()
			selected_card_index = highest_index

func _update_collision_radius() -> void:
	var shape = collision_shape_node.shape as CircleShape2D
	if shape and shape.radius != hand_radius:
		shape.radius = hand_radius

func _update_preview_card() -> void:
	if card_preview:
		card_preview.position = _get_card_position(base_angle)
		card_preview.rotation = deg_to_rad(base_angle + 90.0)

# ------------------------------------------------------------------
# IA (asíncrona para la animación de descarte)
# ------------------------------------------------------------------
func play_turn_ia():
	has_discarded = false
	for card in cards:
		var figure = card.figure
		var number = card.number
		var is_wild = (figure == "ERROR" or number == "ERROR")
		var is_normal_match = (figure == discard_color or number == discard_number) and not card.is_wild
		if is_normal_match or is_wild:
			await _discard_card_as_npc(card, is_wild)
			return

func _discard_card_as_npc(card: Node2D, is_wild: bool) -> void:
	var parent_table = get_parent()

	# 1. Aplicar efectos al estado de la mesa
	if not is_wild:
		parent_table.discard_color = card.figure
		parent_table.discard_number = card.number
		if card.is_reverse:
			parent_table.reverse_active = not parent_table.reverse_active
			if parent_table.npc_hands.size() == 1:
				parent_table.skip_next_turn = true
		if card.is_skip:
			parent_table.skip_next_turn = true
		if card.is_draw2:
			parent_table.plus2_stack = 2
			parent_table.skip_next_turn = true
	else:
		var colors = ["Cuadrado", "Equis", "Triangulo", "Circulo"]
		var random_color = colors[randi() % colors.size()]
		parent_table.discard_color = random_color
		parent_table.discard_number = "ERROR"
		card.figure = random_color
		card.is_wild = true

	# 2. Revelar la carta SIEMPRE (antes de la animación)
	card.reveal_card()

	# 3. Remover la carta de la mano (solo del array, no del árbol)
	var idx = cards.find(card)
	if idx != -1:
		remove_card(idx)

	# 4. Cambiar el padre a la mesa y fijar su posición actual
	var global_pos = card.global_position
	card.change_parent(parent_table)
	card.global_position = global_pos

	# 5. Animar el desplazamiento hasta la pila de descarte
	await parent_table.animate_npc_discard(card)

	# 6. Colocar exactamente en la pila
	card.rotation = 0
	card.position = parent_table.discard_position
	if parent_table.has_method("npc_discard_card"):
		parent_table.npc_discard_card(card)

	has_discarded = true

# ------------------------------------------------------------------
func is_empty() -> bool:
	return cards.is_empty()

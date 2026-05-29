extends Node2D

# ------------------------------------------------------------------ 
#  Referencias a escenas
# ------------------------------------------------------------------
@onready var MainCardScene: PackedScene = preload("res://Scenes/Cards/main_cards.tscn")
@onready var HandScene: PackedScene = preload("res://Scenes/hand.tscn")
@onready var main_menu_scene: PackedScene = preload("res://Menus/scenes/main_menu.tscn")
@onready var chat_scene: PackedScene = preload("res://Scenes/Chat.tscn")
@onready var victory_scene: PackedScene = preload("res://Scenes/GanasteFinal.tscn")
@onready var defeat_scene: PackedScene = preload("res://Scenes/GameOver.tscn")

# ------------------------------------------------------------------
#  Referencias a nodos de la escena
# ------------------------------------------------------------------
@onready var deck_area: Area2D = $CanvasLayer/Deck/Sprite2D/Area2D

@onready var hand: Hand = $CanvasLayer/Hand
@onready var video_background: VideoStreamPlayer = $Sprite2D/VideoStreamPlayer
@onready var player_indicator: Sprite2D = $CanvasLayer/Indicadores/Indicador
@onready var npc_indicators := {
	0: $CanvasLayer/Indicadores/Indicador2,
	1: $CanvasLayer/Indicadores/Indicador3,
	2: $CanvasLayer/Indicadores/Indicador4
}

# Posición de la pila de descarte
var discard_position := Vector2(496, 315)

# ------------------------------------------------------------------
#  Estados del juego
# ------------------------------------------------------------------
enum Turn {
	PLAYER,
	NPC
}

var discard_color: String = ""
var discard_number: String = "S"
var current_color: String = ""
var current_number: String = "S"
var card_queue: Array = []
var body: MainCards = null
var npc_hands: Array = []                     # Ordenado en sentido horario: derecha, arriba, izquierda
@export var num_npcs: int = 3
var game_over: bool = false
var player_won: bool = false

var current_turn: int = Turn.PLAYER
var current_npc_index: int = 0
var reverse_active := false
var skip_next_turn := false
var plus2_stack := 0
var game_paused := false
var npc_turn_delayed := false

var scene_changed := false


# ------------------------------------------------------------------
#  Ciclo de vida
# ------------------------------------------------------------------
func _ready():
	video_background.play()
	start_game()

func _process(_delta):
	if game_over and not scene_changed:
		show_end_screen()

# ------------------------------------------------------------------
#  Inicialización del juego
# ------------------------------------------------------------------
func start_game():
	var first_card = MainCardScene.instantiate()
	first_card.position = Vector2(496, 315)
	first_card.max_number = 10
	first_card.max_color = 40
	add_child(first_card)
	card_queue.append(first_card)

	instantiate_npc_hands()

	for i in range(7):
		instant_take_card(hand)
	for npc_hand in npc_hands:
		for j in range(7):
			instant_take_card(npc_hand)

	hand.card_discarded.connect(_on_player_card_discarded)

	player_indicator.texture = preload("res://Sprites/pixil-frame-0.png")
	current_turn = Turn.PLAYER


# ------------------------------------------------------------------
#  Instanciación de manos de NPCs y reordenamiento horario
# ------------------------------------------------------------------
func instantiate_npc_hands():
	var temp_hands = []
	for i in range(num_npcs):
		var new_hand = HandScene.instantiate()
		new_hand.is_npc = true
		temp_hands.append(new_hand)

		match i:
			0:  # Arriba
				new_hand.position = Vector2(576, -883)
				new_hand.base_angle = -90
			1:  # Derecha
				new_hand.position = Vector2(2030, 324)
				new_hand.base_angle = 180
			2:  # Izquierda
				new_hand.position = Vector2(-883, 324)
				new_hand.base_angle = 0

	# Orden antihorario: izquierda (2), arriba (0), derecha (1)
	npc_hands = [temp_hands[2], temp_hands[0], temp_hands[1]]

	# Indicadores: izquierda (2), arriba (0), derecha (1)
	var indicator_map = [
		npc_indicators.get(2, null),
		npc_indicators.get(0, null),
		npc_indicators.get(1, null)
	]

	for i in range(npc_hands.size()):
		var hand_node = npc_hands[i]
		add_child(hand_node)
		hand_node.npc_indicator = indicator_map[i]
		if hand_node.npc_indicator:
			hand_node.npc_indicator.texture = preload("res://Sprites/pixil-frame-0 (1).png")

# ------------------------------------------------------------------
#  Lógica de turnos (solo si el juego no está pausado)
# ------------------------------------------------------------------
func _physics_process(_delta):
	if game_over or game_paused:
		return
	run_turn_logic()


func run_turn_logic():
	match current_turn:
		Turn.PLAYER:
			handle_player_turn()
		Turn.NPC:
			handle_npc_turn()


# ------------------------------------------------------------------
#  Turno del jugador
# ------------------------------------------------------------------
func handle_player_turn():
	player_indicator.texture = preload("res://Sprites/pixil-frame-0.png")
	hand.is_my_turn = true

	if skip_next_turn:
		game_paused = true
		if plus2_stack > 0:
			for _i in range(plus2_stack):
				await animate_draw_card(hand)
			plus2_stack = 0
		skip_next_turn = false
		hand.is_my_turn = false
		player_indicator.texture = preload("res://Sprites/pixil-frame-0 (1).png")
		advance_turn()
		game_paused = false
		return

	if hand.is_empty():
		game_over = true
		player_won = true
		return


# ------------------------------------------------------------------
#  Turno de un NPC
# ------------------------------------------------------------------
func handle_npc_turn():
	if current_npc_index < 0 or current_npc_index >= npc_hands.size():
		return

	game_paused = true

	var npc_hand = npc_hands[current_npc_index]
	# Encender indicador directamente
	if npc_hand.npc_indicator:
		npc_hand.npc_indicator.texture = preload("res://Sprites/pixil-frame-0.png")

	if not npc_turn_delayed and not skip_next_turn:
		npc_turn_delayed = true
		await get_tree().create_timer(1.5).timeout

	if skip_next_turn:
		if plus2_stack > 0:
			for _i in range(plus2_stack):
				await animate_draw_card(npc_hand)
			plus2_stack = 0
		skip_next_turn = false
		finish_npc_turn()
		game_paused = false
		return

	npc_hand.discard_color = discard_color
	npc_hand.discard_number = discard_number
	await npc_hand.play_turn_ia()

	if not npc_hand.has_discarded:
		await animate_draw_card(npc_hand)
	else:
		hand.can_play = false

	if npc_hand.is_empty():
		game_over = true
		player_won = false
		game_paused = false
		return

	finish_npc_turn()
	game_paused = false


# ------------------------------------------------------------------
#  Finalizar turno NPC
# ------------------------------------------------------------------
func finish_npc_turn():
	# Apagar indicador del NPC actual
	var npc_hand = npc_hands[current_npc_index]
	if npc_hand.npc_indicator:
		npc_hand.npc_indicator.texture = preload("res://Sprites/pixil-frame-0 (1).png")
	npc_turn_delayed = false
	advance_turn()


# ------------------------------------------------------------------
#  Cambiar al siguiente turno
# ------------------------------------------------------------------
func advance_turn():
	hand.is_my_turn = false

	if current_turn == Turn.PLAYER:
		if reverse_active:
			current_turn = Turn.NPC
			current_npc_index = npc_hands.size() - 1
		else:
			current_turn = Turn.NPC
			current_npc_index = 0
		player_indicator.texture = preload("res://Sprites/pixil-frame-0 (1).png")
		return

	var step = -1 if reverse_active else 1
	var next_index = current_npc_index + step

	if next_index >= npc_hands.size() or next_index < 0:
		current_turn = Turn.PLAYER
		current_npc_index = 0
		player_indicator.texture = preload("res://Sprites/pixil-frame-0.png")
	else:
		current_npc_index = next_index


# ------------------------------------------------------------------
#  Robo instantáneo (sin animación)
# ------------------------------------------------------------------
func instant_take_card(parent_hand: Node2D):
	var new_card = MainCardScene.instantiate()
	parent_hand.add_card(new_card)


# ------------------------------------------------------------------
#  Robo con animación (mazo -> mano)
# ------------------------------------------------------------------
func animate_draw_card(target_hand: Hand):
	var card = MainCardScene.instantiate()
	card.revealed = not target_hand.is_npc
	card.global_position = deck_area.global_position
	add_child(card)

	var target_local = target_hand.get_new_card_position()
	var target_global = target_hand.to_global(target_local)

	var tween = create_tween()
	tween.tween_property(card, "global_position", target_global, 0.3).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

	remove_child(card)
	target_hand.add_card(card)
	card.position = target_local


# ------------------------------------------------------------------
#  Animación de descarte de un NPC
# ------------------------------------------------------------------
func animate_npc_discard(card: MainCards):
	var tween = create_tween()
	tween.tween_property(card, "global_position", discard_position, 0.3).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(card, "rotation", 0.0, 0.3).set_ease(Tween.EASE_IN_OUT)
	await tween.finished


# ------------------------------------------------------------------
#  Añadir carta a la pila de descarte (NPC)
# ------------------------------------------------------------------
func npc_discard_card(card):
	card_queue.append(card)
	if card_queue.size() > 1:
		var old_card = card_queue.pop_front()
		if is_instance_valid(old_card):
			old_card.queue_free()


# ------------------------------------------------------------------
#  Jugador descarta una carta (señal de la mano)
# ------------------------------------------------------------------
func _on_player_card_discarded(card: MainCards):
	if current_turn != Turn.PLAYER:
		return

	card_queue.append(card)
	if card_queue.size() > 1:
		var old_card = card_queue.pop_front()
		if is_instance_valid(old_card):
			old_card.queue_free()

	# Victoria instantánea al quedarse sin cartas
	if hand.is_empty():
		game_over = true
		player_won = true
		return

	# Procesar efectos de la carta
	if card.is_wild:
		game_paused = true
		var chat_instance = chat_scene.instantiate()
		add_child(chat_instance)
		chat_instance.position = Vector2.ZERO
		chat_instance.color_selected.connect(_on_color_selected.bind(card))
		await chat_instance.color_selected
		game_paused = false
	else:
		discard_color = card.figure
		discard_number = card.number
		if card.is_reverse:
			reverse_active = not reverse_active
			if npc_hands.size() == 1:
				skip_next_turn = true
		if card.is_skip:
			skip_next_turn = true
		if card.is_draw2:
			skip_next_turn = true
			plus2_stack = 2

	hand.can_play = false
	advance_turn()


# ------------------------------------------------------------------
#  Elección de color del comodín (jugador)
# ------------------------------------------------------------------
func _on_color_selected(color: String, wild_card: MainCards):
	discard_color = color
	discard_number = "ERROR"
	wild_card.figure = color
	wild_card.is_wild = true
	wild_card.reveal_card()
	game_paused = false


# ------------------------------------------------------------------
#  Validación de la carta arrastrada
# ------------------------------------------------------------------
func _on_area_2d_area_entered(area):
	if current_turn != Turn.PLAYER:
		return
	if not area.get_parent() is Sprite2D:
		return

	var sprite = area.get_parent()
	body = sprite.get_parent() as MainCards
	if not body:
		return

	var figure = body.figure
	var number = body.number

	if discard_color == "" and discard_number == "S":
		discard_color = figure
		discard_number = number
		current_color = figure
		current_number = number
		hand.can_play = true
		body.is_valid = true
		return

	current_color = discard_color
	current_number = discard_number
	var is_valid = false

	if figure == discard_color or number == discard_number or figure == "ERROR" or number == "ERROR":
		is_valid = true
		if figure != "ERROR":
			current_color = figure
		if number != "ERROR":
			current_number = number

	if is_valid:
		hand.can_play = true
		body.is_valid = true
	else:
		hand.can_play = false
		body.is_valid = false


func _on_area_2d_area_exited(_area):
	if hand.can_play:
		hand.can_play = false
		if body:
			body.is_valid = false
		current_color = discard_color
		current_number = discard_number


# ------------------------------------------------------------------
#  Clic en el mazo (robar)
# ------------------------------------------------------------------
func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if current_turn == Turn.PLAYER and not game_paused:
			game_paused = true
			await animate_draw_card(hand)
			hand.is_my_turn = false
			hand.can_play = false
			player_indicator.texture = preload("res://Sprites/pixil-frame-0 (1).png")
			advance_turn()
			game_paused = false


# ------------------------------------------------------------------
#  Final del juego
# ------------------------------------------------------------------
func show_end_screen():
	scene_changed = true
	var end_instance
	if player_won:
		end_instance = victory_scene.instantiate()
	else:
		end_instance = defeat_scene.instantiate()
	end_instance.z_index = 1000
	$CanvasLayer.add_child(end_instance)


# ------------------------------------------------------------------
#  Volver al menú principal
# ------------------------------------------------------------------
func _on_button_pressed():
	get_tree().change_scene_to_packed(main_menu_scene)

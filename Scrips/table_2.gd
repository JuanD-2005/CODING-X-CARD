extends Node2D

@onready var MainCardScene: PackedScene = preload("res://Scenes/Cards/main_cards.tscn")
@onready var handIA: PackedScene = preload("res://Scenes/hand.tscn")
@onready var hand: Hand = $CanvasLayer/Hand
@onready var Scene = preload("res://Menus/scenes/main_menu.tscn")
@onready var Fondo = $Sprite2D/VideoStreamPlayer
@onready var Chat: PackedScene = preload("res://Scenes/Chat.tscn")
@onready var GanasteScene = preload("res://Scenes/PantallaDeGanaste.tscn")
@onready var GameOverScene = preload("res://Scenes/GameOver.tscn")
@onready var Indicador = $CanvasLayer/Indicadores/Indicador
@onready var Indicador2 = $CanvasLayer/Indicadores/Indicador2
@onready var Indicador3 = $CanvasLayer/Indicadores/Indicador3
@onready var Indicador4 = $CanvasLayer/Indicadores/Indicador4

var ColorDiscard: String = ""
var NumberDiscard: String = "S"
var CurrentColor: String = ""
var CurrentNumber: String = "S"
var Card_queue: Array = []
var body: Node2D
var HandIA: Array = []
@export var NPCs: int = 3
var GameOver: bool = false
var Reverse: bool = false
var Cancel: bool = false
var Adder: bool = false
var Change: bool = false

enum Turn {
	PLAYER_TURN,
	NPC1_TURN,
	NPC2_TURN,
	NPC3_TURN
}
var current_turn = Turn.PLAYER_TURN
var ReverseTurns = false
var CancelTurn = false
var AdderTurn = false
var PassTurn = false
var PlayedCard = false
var GamePaused = false
var npc_turn_paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Fondo.play()
	start_game()

func start_game():
	var IntanseCard = MainCardScene.instantiate()
	IntanseCard.position = Vector2(496,315)
	IntanseCard.intRamdonN = 10
	IntanseCard.intRamdonC = 40
	add_child(IntanseCard)
	Card_queue.append(IntanseCard)
	
	IntanseHandIA()
	
	for i in 7:
		TakeCard(hand)
	
	for vs in NPCs:
		for j in 7:
			TakeCard(HandIA[vs])
	
	hand.ClickRemove.connect(CleanDiscard)
	current_turn = Turn.PLAYER_TURN
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
var i = 1
func _process(delta):
	if !GameOver:
		if !GamePaused:
			Turns()
	else:
		if i == 1:
			ChangeScene()

func ChangeScene():
	if hand.WinPlayer:
		var IntanseGanaste = GanasteScene.instantiate()
		IntanseGanaste.set_z_index(1000)
		$CanvasLayer.add_child(IntanseGanaste)
		i = 2
	else:
		var IntanseGameOver = GameOverScene.instantiate()
		IntanseGameOver.set_z_index(1000)
		$CanvasLayer.add_child(IntanseGameOver)
		i = 2

func Turns():
	match current_turn:
		Turn.PLAYER_TURN:
			Indicador.texture = preload("res://Sprites/pixil-frame-0.png")
			hand.Turn = true
			PlayerTurn()
			GameOver = hand.WinningHand()
			if GameOver:
				hand.WinPlayer = true
		Turn.NPC1_TURN:
			if HandIA.size() == 1 or HandIA.size() == 2:
				Indicador2.texture = preload("res://Sprites/pixil-frame-0.png")
			else:
				Indicador4.texture = preload("res://Sprites/pixil-frame-0.png")
			
			if !npc_turn_paused and !CancelTurn:
				npc_turn_paused = true
				GamePaused = true
				await get_tree().create_timer(1.5).timeout
			
			if HandIA.size() == 1 or HandIA.size() == 2:
				NpcTurn(HandIA[0])
				GameOver = HandIA[0].WinningHand()
			else:
				NpcTurn(HandIA[2])
				GameOver = HandIA[2].WinningHand()
			
		Turn.NPC2_TURN:
			if HandIA.size() == 2:
				Indicador3.texture = preload("res://Sprites/pixil-frame-0.png")
			elif HandIA.size() == 3:
				Indicador2.texture = preload("res://Sprites/pixil-frame-0.png")
			
			if !npc_turn_paused and !CancelTurn:
				npc_turn_paused = true
				GamePaused = true
				await get_tree().create_timer(1.5).timeout
			
			if HandIA.size() == 2:
				NpcTurn(HandIA[1])
				GameOver = HandIA[1].WinningHand()
			elif HandIA.size() == 3:
				NpcTurn(HandIA[0])
				GameOver = HandIA[0].WinningHand()
			
		Turn.NPC3_TURN:
			Indicador3.texture = preload("res://Sprites/pixil-frame-0.png")
			if !npc_turn_paused and !CancelTurn:
				npc_turn_paused = true
				GamePaused = true
				await get_tree().create_timer(1.5).timeout
			NpcTurn(HandIA[1])
			GameOver = HandIA[1].WinningHand()
	
	if !hand.Turn:
		if HandIA.size() == 1:
			match current_turn:
				Turn.PLAYER_TURN:
					current_turn = Turn.PLAYER_TURN if ReverseTurns else Turn.NPC1_TURN
				Turn.NPC1_TURN:
					current_turn = Turn.NPC1_TURN if ReverseTurns else Turn.PLAYER_TURN
			if HandIA.size() == 1:
				ReverseTurns = false
			
		elif HandIA.size() == 2:
			match current_turn:
				Turn.PLAYER_TURN:
					current_turn = Turn.NPC2_TURN if ReverseTurns else Turn.NPC1_TURN
				Turn.NPC1_TURN:
					current_turn = Turn.PLAYER_TURN if ReverseTurns else Turn.NPC2_TURN
				Turn.NPC2_TURN:
					current_turn = Turn.NPC1_TURN if ReverseTurns else Turn.PLAYER_TURN
			
		elif  HandIA.size() == 3:
			match current_turn:
				Turn.PLAYER_TURN:
					current_turn = Turn.NPC3_TURN if ReverseTurns else Turn.NPC1_TURN
				Turn.NPC1_TURN:
					current_turn = Turn.PLAYER_TURN if ReverseTurns else Turn.NPC2_TURN
				Turn.NPC2_TURN:
					current_turn = Turn.NPC1_TURN if ReverseTurns else Turn.NPC3_TURN
				Turn.NPC3_TURN:
					current_turn = Turn.NPC2_TURN if ReverseTurns else Turn.PLAYER_TURN
		
		PassTurn = false
		PlayedCard = false
		npc_turn_paused = false
		GamePaused = false
	

func PlayerTurn():
	if PassTurn or PlayedCard:
		hand.Turn = false
		Indicador.texture = preload("res://Sprites/pixil-frame-0 (1).png")
		
		Cancel = false
	elif CancelTurn:
		if AdderTurn:
			for i in 2:
				TakeCard(hand)
			AdderTurn = false
		hand.Turn = false
		Indicador.texture = preload("res://Sprites/pixil-frame-0 (1).png")
		CancelTurn = false
	

func NpcTurn(NpcHand):
	if !CancelTurn:
		CancelTurn = false
		Cancel = false
		Reverse = false
		NpcHand.ColorDiscard = ColorDiscard
		NpcHand.NumberDiscard = NumberDiscard
		NpcHand.IA()
		if !NpcHand.Discard:
			TakeCard(NpcHand)
		else:
			hand.ValidCard = false
		
		if NpcHand == HandIA[0]:
			Indicador2.texture = preload("res://Sprites/pixil-frame-0 (1).png")
		elif NpcHand == HandIA[1]:
			Indicador3.texture = preload("res://Sprites/pixil-frame-0 (1).png")
		elif NpcHand == HandIA[2]:
			Indicador4.texture = preload("res://Sprites/pixil-frame-0 (1).png")
		
	else:
		Reverse = false
		if AdderTurn:
			for i in 2:
				TakeCard(NpcHand)
			AdderTurn = false
		CancelTurn = false
		
		if NpcHand == HandIA[0]:
			Indicador2.texture = preload("res://Sprites/pixil-frame-0 (1).png")
		elif NpcHand == HandIA[1]:
			Indicador3.texture = preload("res://Sprites/pixil-frame-0 (1).png")
		elif NpcHand == HandIA[2]:
			Indicador4.texture = preload("res://Sprites/pixil-frame-0 (1).png")

func IntanseHandIA():
	for i in NPCs:
		HandIA.push_back(handIA.instantiate())
		HandIA[i].Disabled = true
		
		if i == 0:
			HandIA[i].position = Vector2(576,-883)
			HandIA[i].CardAngle = -90
			add_child(HandIA[i])
		elif i == 1:
			HandIA[i].position = Vector2(2030,324)
			HandIA[i].CardAngle = 180
			add_child(HandIA[i])
			
		elif i == 2:
			HandIA[i].position = Vector2(-883,324)
			HandIA[i].CardAngle = 0
			add_child(HandIA[i])

func TakeCard(Parent: Node2D):
	var IntanseCard = MainCardScene.instantiate()
	Parent.AddCard(IntanseCard)

func CleanDiscard(card):
	PlayedCard = true
	Card_queue.append(card)
	
	if Card_queue.size() > 1 :
		var Trash = Card_queue[0]
		Card_queue.remove_at(0)
		Trash.queue_free()
	
	if !Change:
		ColorDiscard = CurrentColor
		NumberDiscard = CurrentNumber
		if Reverse:
			if !ReverseTurns:
				ReverseTurns = true
			else:
				ReverseTurns = false
		elif Cancel:
			CancelTurn = true
			if Adder:
				AdderTurn = true
	elif Change:
		if hand.Turn:
			var ChatChange = Chat.instantiate()
			add_child(ChatChange)
			ChatChange.position = Vector2(0,0)
			GamePaused = true
			await_to_select_color(ChatChange, card)
			
		else:
			ColorDiscard = CurrentColor
			NumberDiscard = CurrentNumber
		
	
	hand.ValidCard = false
	Reverse = false
	Cancel = false
	Adder = false

func await_to_select_color(chat_instance, card):
	chat_instance.connect("color_selected", Callable(self, "on_color_selected"))
	await chat_instance.color_selected
	if ColorDiscard == "Cuadrado":
		card.ColorCard = load("res://Sprites/Rosa.png")
	elif ColorDiscard == "Equis":
		card.ColorCard = load("res://Sprites/Azul.png")
	elif ColorDiscard == "Triangulo":
		card.ColorCard = load("res://Sprites/Verde.png")
	elif ColorDiscard == "Circulo":
		card.ColorCard = load("res://Sprites/Rojo.png")
	card.CardTexture.texture = card.ColorCard

func on_color_selected(color):
	ColorDiscard = color
	NumberDiscard = "ERROR"
	GamePaused = false
	Change = false

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var IntanseCard = MainCardScene.instantiate()
		hand.AddCard(IntanseCard)
		PassTurn = true

func _on_area_2d_area_entered(area):
	if area.get_parent() is Sprite2D:
		var sprite = area.get_parent()
		body = sprite.get_parent()
		var ColorCard = body.get("FigureCard")
		var NumberCard = body.get("NumberCard")
		CurrentColor = ColorDiscard
		CurrentNumber = NumberDiscard
		
		if ColorDiscard == "" and NumberDiscard == "S":
			ColorDiscard = ColorCard
			NumberDiscard = NumberCard
			
		elif ColorDiscard == ColorCard or NumberDiscard == NumberCard and !body.Change:
			CurrentColor = ColorCard
			CurrentNumber = NumberCard
			if body.Reverse:
				Reverse = true
			elif body.Cancel:
				Cancel = true
			elif body.Adder:
				Adder = true
				Cancel = true
			
			hand.ValidCard = true
			body.ValidCard = true
			
		elif ColorCard == "ERROR" or NumberCard == "ERROR":
			if body.Change:
				Change = true
			
			hand.ValidCard = true
			body.ValidCard = true

func _on_area_2d_area_exited(area):
	if hand.ValidCard:
		hand.ValidCard = false
		body.ValidCard = false
		if Reverse:
			Reverse = false
		elif Cancel:
			if Adder:
				Adder = false
			Cancel = false
		elif Change:
			Change = false
		CurrentColor = ColorDiscard
		CurrentNumber = NumberDiscard
	

func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(Scene)

@tool
class_name Hand extends Node2D

signal ClickRemove(card: Node2D)

@export var HandsRadius: int = 1000
@export var CardAngle: float = 90
@export var AngleLimit: float = 25
@export var MCSA: float = 5
@export var Disabled: bool = false

@onready var Test = $MainCards
@onready var CollisionCard: CollisionShape2D = $Area2D/CardCollision

var hand: Array = []
var Touched: Array = []
var CardSelectIndex: int = -1
var IsInRoot: bool = false
var ValidCard:bool = false
var CurrentCard
var Turn: bool = true
var ColorDiscard: String = ""
var NumberDiscard: String = ""
var Discard:bool = false
var Winner:bool = false
var WinPlayer:bool = false

func WinningHand() -> bool:
	if hand.is_empty():
		Winner = true
	else:
		Winner = false
	
	return Winner

func AddCard(Card: Node2D):
	if Disabled:
		Card.Reveal = false
	hand.push_back(Card)
	add_child(Card)
	if not Disabled:
		Card.mouse_entered.connect(HandleCardTouched)
		Card.mouse_exited.connect(HandleCardUntouched)
	RepositionCards()

func RepositionCards():
	var CardSpread = min(AngleLimit / hand.size(), MCSA)
	var CurrentAngle = -(CardSpread * (hand.size() - 1))/2 - CardAngle
	
	for card in hand:
		UpdateHand(card, CurrentAngle)
		CurrentAngle += CardSpread

func GetCardPosition(AngleDeg: float) -> Vector2:
	var x: float = HandsRadius * cos(deg_to_rad(AngleDeg))
	var y: float = HandsRadius * sin(deg_to_rad(AngleDeg))
	
	return Vector2(int(x), int(y))

func UpdateHand(card: Node2D, AngleDeg: float):
	card.set_position(GetCardPosition(AngleDeg))
	card.set_rotation(deg_to_rad(AngleDeg + 90))

func HandleCardTouched(card):
	if not Touched.has(card):
		Touched.push_back(card)

func HandleCardUntouched(card):
	if Touched.has(card):
		Touched.remove_at(Touched.find(card))

func Removed(cardSelectIndex):
	var RemoveCard = hand[cardSelectIndex]
	if hand.has(RemoveCard):
		hand.remove_at(cardSelectIndex)
	if Touched.has(RemoveCard):
		Touched.remove_at(Touched.find(RemoveCard))
	RepositionCards()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if Turn:
		if not Disabled:
			if event.is_action_pressed("Mouse_click") && CardSelectIndex >= 0:
				if IsInRoot:
					if not ValidCard:
						CurrentCard.MoveOriginalParent(self)
					else:
						ClickRemove.emit(hand[CardSelectIndex])
						Removed(CardSelectIndex)
					IsInRoot = false
					
				else:
					CurrentCard = hand[CardSelectIndex]
					hand[CardSelectIndex].ClickRemove = false
					hand[CardSelectIndex].ChangeParent(get_parent())
					IsInRoot = true
				
				
				CurrentCard.Follow()
				CardSelectIndex = -1
				ValidCard = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	CardSelectIndex = -1
	for card in hand:
		card.Unhighlight()
	
	if Touched.size() > 0:
		var HighIndex: int = -1
		
		for TouchedCard in Touched:
			HighIndex = max(HighIndex, hand.find(TouchedCard))
		
		if not Disabled:
			if HighIndex >= 0 && HighIndex < hand.size():
				hand[HighIndex].Highlight()
				CardSelectIndex = HighIndex
		
	
	if (CollisionCard.shape as CircleShape2D).radius != HandsRadius:
		(CollisionCard.shape as CircleShape2D).set_radius(HandsRadius)
	
	Test.set_position(GetCardPosition(CardAngle))
	Test.set_rotation(deg_to_rad(CardAngle + 90))

func IA():
	Discard = false
	
	for card in hand:
		if card.get("FigureCard") == ColorDiscard or card.get("NumberCard") == NumberDiscard and !card.Change:
			card.ChangeParent(get_parent())
			get_parent().CurrentColor = card.get("FigureCard")
			get_parent().CurrentNumber = card.get("NumberCard")
			if card.Reverse:
				get_parent().Reverse = true
			elif card.Cancel:
				get_parent().Cancel = true
			elif card.Adder:
				get_parent().Adder = true
				get_parent().Cancel = true
			get_parent().CleanDiscard(card)
			Removed(hand.find(card))
			card.RevealCard()
			card.rotation = 0
			card.position = Vector2(496,315)
			Discard = true
			break
			
		elif card.get("FigureCard") == "ERROR" or card.get("NumberCard") == "ERROR":
			card.ChangeParent(get_parent())
			if card.Change:
				get_parent().Change = true
			
			var RamdonColor = randi() % 4 + 1
			
			if RamdonColor == 1:
				card.FigureCard = "Cuadrado"
				get_parent().CurrentColor = card.FigureCard
				get_parent().CurrentNumber = "ERROR"
				
			elif RamdonColor == 2:
				card.FigureCard = "Equis"
				get_parent().CurrentColor = card.FigureCard
				get_parent().CurrentNumber = "ERROR"
				
			elif RamdonColor == 3:
				card.FigureCard = "Triangulo"
				get_parent().CurrentColor = card.FigureCard
				get_parent().CurrentNumber = "ERROR"
				
			elif RamdonColor == 4:
				card.FigureCard = "Circulo"
				get_parent().CurrentColor = card.FigureCard
				get_parent().CurrentNumber = "ERROR"
				
			
			get_parent().CleanDiscard(card)
			get_parent().Change = false
			Removed(hand.find(card))
			card.RevealCard()
			card.rotation = 0
			card.position = Vector2(496,315)
			Discard = true
			break
	

class_name MainCards extends Node2D

signal mouse_entered(card: MainCards)
signal mouse_exited(card: MainCards)
@export var ColorCard: Texture
@export var FigureCard: String = ""
@export var NumberCard: String = ""
@export var Reverse: bool = false
@export var Cancel: bool = false
@export var Adder: bool = false
@export var Change: bool = false

var Originalz_index
var CardPosition: Vector2
var CardRotation: float
var Following: bool = false
var ValidCard: bool = false
var ClickRemove: bool = false
var Reveal: bool = true
var intRamdonN: int = 13
var intRamdonC: int = 56

@onready var NumberLbl: Label = $CardSprite/NumberLbl
@onready var CardTexture: Sprite2D = $CardSprite
@onready var CardArea: Area2D = $CardSprite/Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Originalz_index = CardTexture.z_index
	var RamdonNumber = randi() % intRamdonN
	var RamdonColor = randi() % intRamdonC + 1
	
	if RamdonColor >= 0 and RamdonColor <= 12:
		FigureCard = "Cuadrado"
		if Reveal:
			ColorCard = load("res://Sprites/Cuadrado.png")
		else:
			ColorCard = load("res://Sprites/Default.png")
		
	elif RamdonColor >= 13 and RamdonColor <= 25:
		FigureCard = "Equis"
		if Reveal:
			ColorCard = load("res://Sprites/Equis.png")
		else:
			ColorCard = load("res://Sprites/Default.png")
		
	elif RamdonColor >= 26 and RamdonColor <= 38:
		FigureCard = "Triangulo"
		if Reveal:
			ColorCard = load("res://Sprites/Triangulo.png")
		else:
			ColorCard = load("res://Sprites/Default.png")
		
	elif RamdonColor >= 39 and RamdonColor <= 51:
		FigureCard = "Circulo"
		if Reveal:
			ColorCard = load("res://Sprites/Circulo.png")
		else:
			ColorCard = load("res://Sprites/Default.png")
		
	elif RamdonColor >= 52:
		FigureCard = "ERROR"
		NumberCard = "ERROR"
		Change = true
		
		if Reveal:
			ColorCard = load("res://Sprites/3RR05.png")
		else:
			ColorCard = load("res://Sprites/Default.png")
		
	
	if !Change:
		if RamdonNumber == 0:
				NumberCard = ""
			
		elif  RamdonNumber == 1:
			NumberCard = "I"
			
		elif RamdonNumber == 2:
			NumberCard = "II"
			
		elif RamdonNumber == 3:
			NumberCard = "III"
			
		elif RamdonNumber == 4:
			NumberCard = "IV"
			
		elif RamdonNumber == 5:
			NumberCard = "V"
			
		elif RamdonNumber == 6:
			NumberCard = "VI"
			
		elif RamdonNumber == 7:
			NumberCard = "VII"
			
		elif RamdonNumber == 8:
			NumberCard = "VIII"
			
		elif RamdonNumber == 9:
			NumberCard = "IX"
		elif RamdonNumber == 10:
			Reverse = true
			NumberCard = "X"
			
			if FigureCard == "Cuadrado":
				if Reveal:
					ColorCard = load("res://Sprites/Cuadrado Reverse.png")
				else:
					ColorCard = load("res://Sprites/Default.png")
				
			elif FigureCard == "Equis":
				if Reveal:
					ColorCard = load("res://Sprites/Equis Reverse.png")
				else:
					ColorCard = load("res://Sprites/Default.png")
				
			elif FigureCard == "Triangulo":
				if Reveal:
					ColorCard = load("res://Sprites/Triangulo Reverse.png")
				else:
					ColorCard = load("res://Sprites/Default.png")
				
			elif FigureCard == "Circulo":
				if Reveal:
					ColorCard = load("res://Sprites/Circulo Reverse.png")
				else:
					ColorCard = load("res://Sprites/Default.png")
			
		elif RamdonNumber == 11:
			Cancel = true
			NumberCard = "XI"
			
			if FigureCard == "Cuadrado":
				if Reveal:
					ColorCard = load("res://Sprites/Cuadrado Cancel.png")
				else:
					ColorCard = load("res://Sprites/Default.png")
				
			elif FigureCard == "Equis":
				if Reveal:
					ColorCard = load("res://Sprites/Equis Cancel.png")
				else:
					ColorCard = load("res://Sprites/Default.png")
				
			elif FigureCard == "Triangulo":
				if Reveal:
					ColorCard = load("res://Sprites/Triangulo Cancel.png")
				else:
					ColorCard = load("res://Sprites/Default.png")
				
			elif FigureCard == "Circulo":
				if Reveal:
					ColorCard = load("res://Sprites/Circulo Cancel.png")
				else:
					ColorCard = load("res://Sprites/Default.png")
			
		elif RamdonNumber == 12:
			Adder = true
			NumberCard = "XII"
			
			if FigureCard == "Cuadrado":
				if Reveal:
					ColorCard = load("res://Sprites/Cuadrado Sumador.png")
				else:
					ColorCard = load("res://Sprites/Default.png")
				
			elif FigureCard == "Equis":
				if Reveal:
					ColorCard = load("res://Sprites/Equis Sumador.png")
				else:
					ColorCard = load("res://Sprites/Default.png")
				
			elif FigureCard == "Triangulo":
				if Reveal:
					ColorCard = load("res://Sprites/Triangulo Sumador.png")
				else:
					ColorCard = load("res://Sprites/Default.png")
				
			elif FigureCard == "Circulo":
				if Reveal:
					ColorCard = load("res://Sprites/Circulo Sumador.png")
				else:
					ColorCard = load("res://Sprites/Default.png")
	
	CardTexture.texture = ColorCard
	
	if Reveal and !Reverse and !Cancel and !Adder and !Change:
		NumberLbl.set_text(NumberCard)

func RevealCard():
	if !Reverse and !Cancel and !Adder and !Change:
		if FigureCard == "Cuadrado":
			ColorCard = load("res://Sprites/Cuadrado.png")
		elif FigureCard == "Equis":
			ColorCard = load("res://Sprites/Equis.png")
		elif FigureCard == "Triangulo":
			ColorCard = load("res://Sprites/Triangulo.png")
		elif FigureCard == "Circulo":
			ColorCard = load("res://Sprites/Circulo.png")
		NumberLbl.set_text(NumberCard)
		
	elif Change:
		if FigureCard == "Cuadrado":
			ColorCard = load("res://Sprites/Rosa.png")
		elif FigureCard == "Equis":
			ColorCard = load("res://Sprites/Azul.png")
		elif FigureCard == "Triangulo":
			ColorCard = load("res://Sprites/Verde.png")
		elif FigureCard == "Circulo":
			ColorCard = load("res://Sprites/Rojo.png")
		
	elif Reverse:
		if FigureCard == "Cuadrado":
			ColorCard = load("res://Sprites/Cuadrado Reverse.png")
		elif FigureCard == "Equis":
			ColorCard = load("res://Sprites/Equis Reverse.png")
		elif FigureCard == "Triangulo":
			ColorCard = load("res://Sprites/Triangulo Reverse.png")
		elif FigureCard == "Circulo":
			ColorCard = load("res://Sprites/Circulo Reverse.png")
		
	elif Cancel:
		if FigureCard == "Cuadrado":
			ColorCard = load("res://Sprites/Cuadrado Cancel.png")
		elif FigureCard == "Equis":
			ColorCard = load("res://Sprites/Equis Cancel.png")
		elif FigureCard == "Triangulo":
			ColorCard = load("res://Sprites/Triangulo Cancel.png")
		elif FigureCard == "Circulo":
			ColorCard = load("res://Sprites/Circulo Cancel.png")
		
	elif Adder:
		if FigureCard == "Cuadrado":
			ColorCard = load("res://Sprites/Cuadrado Sumador.png")
		elif FigureCard == "Equis":
			ColorCard = load("res://Sprites/Equis Sumador.png")
		elif FigureCard == "Triangulo":
			ColorCard = load("res://Sprites/Triangulo Sumador.png")
		elif FigureCard == "Circulo":
			ColorCard = load("res://Sprites/Circulo Sumador.png")
		
	elif Change:
		if FigureCard == "Cuadrado":
			ColorCard = load("res://Sprites/Rosa.png")
		elif FigureCard == "Equis":
			ColorCard = load("res://Sprites/Azul.png")
		elif FigureCard == "Triangulo":
			ColorCard = load("res://Sprites/Verde.png")
		elif FigureCard == "Circulo":
			ColorCard = load("res://Sprites/Rojo.png")
	
	CardTexture.texture = ColorCard

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Following:
		position = get_global_mouse_position()

func Highlight():
	CardTexture.z_index = 100

func Unhighlight():
	CardTexture.z_index = Originalz_index

func _on_area_2d_mouse_entered():
	mouse_entered.emit(self)

func _on_area_2d_mouse_exited():
	mouse_exited.emit(self)

func Follow():
	if not Following:
		CardPosition = position
		CardRotation = rotation
		rotation = 0
		Following = true
	else:
		if ValidCard:
			position = Vector2(496,315)
		else:
			position = CardPosition
			rotation = CardRotation
			ClickRemove = false
		Following = false

func ChangeParent(NewParent):
	if NewParent != null:
		var Parent = get_parent()
		Parent.remove_child(self)
		NewParent.add_child(self)

func MoveOriginalParent(OriginalParent: Node2D):
	if OriginalParent != null:
		var Parent = get_parent()
		Parent.remove_child(self)
		OriginalParent.add_child(self)

extends Control

signal color_selected(color: String)

@onready var chat_display = $ChatDisplay
@onready var chat_input = $ChatInput
@onready var send_button = $SendButton

func _ready():
	chat_display.text += "Escriba una figura:\n"
	chat_display.text += "|Cuadrado\n"
	chat_display.text += "|Equis\n"
	chat_display.text += "|Triangulo\n"
	chat_display.text += "|Circulo\n\n"

func _on_send_button_pressed():
	_send_message()

func _on_chat_input_text_submitted(new_text):
	_send_message()

func _send_message():
	var message = chat_input.text
	if message != "":
		chat_display.text += message + "\n"
		chat_input.clear()
		if message in ["Cuadrado", "Equis", "Triangulo", "Circulo"]:
			emit_signal("color_selected", message)
			queue_free()
		



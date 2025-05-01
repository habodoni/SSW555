extends Control

@onready var card_text = $Panel/Label
@onready var next_button = $Panel/Button

var cards: Array = []
var current_index := 0
var on_done_callback = null

func _ready():
	next_button.pressed.connect(_on_next_pressed)

func show_cards(new_cards: Array, callback = null) -> void:
	cards = new_cards
	current_index = 0
	on_done_callback = callback
	card_text.text = cards[current_index]
	$DimBackground.visible = true
	show()

func _on_next_pressed() -> void:
	get_parent().get_parent().astronaut_1.health = 100
	get_parent().get_parent().astronaut_2.health = 100
	get_parent().get_parent().astronaut_3.health = 100
	current_index += 1
	if current_index < cards.size():
		card_text.text = cards[current_index]
	else:
		hide()
		$DimBackground.visible = false
		get_parent().end_cards()
		if on_done_callback:
			on_done_callback.call()

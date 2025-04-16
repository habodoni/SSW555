extends Node2D

var astronaut = preload("res://Astronaut/Astronaut.tscn")  # Preloads at compile-time

@onready var oxygen_minigame = $ElektronMinigame
@onready var oxygen_minigame_marker = $OxygenTaskMarker

@onready var minigame_2 = $SystemDiagnostics
@onready var minigame_2_marker = $TaskMarker2

@onready var minigame_3 = $Navigation
@onready var minigame_3_marker = $TaskMarker3

var task_deck = []

var minigame_active = false

var count = 0
var cardDeal = 250


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var astronaut_1 = astronaut.instantiate()
	add_child(astronaut_1)
	astronaut_1.setup(true, 0, 0)
	var astronaut_2 = astronaut.instantiate()
	add_child(astronaut_2)
	astronaut_2.setup(false, 416, -180)
	stack_deck()

func stack_deck():
	oxygen_minigame_marker.setup(oxygen_minigame)
	minigame_2_marker.setup(minigame_2)
	minigame_3_marker.setup(minigame_3)
	minigame_3.offset(770, -320)
	
	oxygen_minigame_marker.deactivate()
	minigame_2_marker.deactivate()
	minigame_3_marker.deactivate()
	task_deck = [oxygen_minigame_marker, minigame_2_marker, minigame_3_marker]
	task_deck.shuffle()

func deal_deck():
	task_deck.pop_at(0).activate()

func set_minigame_active(active: bool):
	minigame_active = active
	if active:
		oxygen_minigame_marker.light.hide()
		minigame_2_marker.light.hide()
		minigame_3_marker.light.hide()
	else:
		oxygen_minigame_marker.light.show()
		minigame_2_marker.light.show()
		minigame_3_marker.light.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not minigame_active:
		if (count == cardDeal && task_deck.size() != 0):
			deal_deck()
			count = 0
		else:
			count += 1

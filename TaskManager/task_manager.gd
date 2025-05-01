extends Node2D

var tasks = ["Navigate to Ganymede", "Replace Oxygen Tank", "Manage Human Waste", "All Tasks Complete: Send to mission control"]
var task_markers = []
var tasks_done = 0
var intro_cards = [
	"Welcome to ISS Expedition Alpha. You are about to begin a critical space mission...",
	"Each astronaut on your crew has a special role...",
	"Use the WASD keys or Arrow keys to move your astronaut around the ship...",
	"You will find food packs floating in the ship...",
	"Pay close attention to your ship's resources...",
	"If any resource reaches zero, the mission will fail...",
	"Press [E] near terminals to engage with computers or start a mini-game.",	
	"Press [X] to switch between crew members at any time.",
	"Mission Control will check in during your journey...",
	"Good luck, astronaut. Your journey starts now..."
]

var outro_cards = [
	"Congratulations, astronaut. You have completed all mission objectives...",
	"Your teamwork and quick thinking kept the ship and crew safe...",
	"The data you gathered will help future explorers...",
	"Mission Control thanks you for your courage...",
	"Mission Complete. \nWelcome home.\n [Press next to restart]"
]

@onready var instruction_popup = $InstructionPopup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = "Task:"
	$Label.visible = true
	instruction_popup.show_cards(intro_cards)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var label_node = $Label
	var display_text = ""
	if tasks_done < tasks.size():
		display_text = "Task: " + tasks[tasks_done]
	else:
		display_text = "You won!"
	label_node.text = display_text

func set_task_markers(markers: Array):
	task_markers = markers
	for task_marker in task_markers:
		task_marker.deactivate()
	task_markers[0].activate()

func task_done():
	task_markers[tasks_done].deactivate()
	task_markers[tasks_done].end_task()
	tasks_done += 1

	if tasks_done < tasks.size():
		task_markers[tasks_done].activate()
	else:
		instruction_popup.show_cards(outro_cards)

func end_cards():
	if tasks_done < tasks.size():
		get_parent().astronaut_1.health = 100
	else:
		get_tree().change_scene_to_file("res://SpaceTravel/SpaceTravel.tscn")

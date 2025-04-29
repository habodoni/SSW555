extends Control
@export var astronaut: Node

# Oxygen system settings
@export var max_oxygen: int = 100
var oxygen_level: float
var bubbles_present: bool = false
var liquid_unit_damaged: bool = true
var is_oxygen_critical: bool = false
var warning_threshold := 90.0
var Task_Manager = null

# Restart sequence logic
var command_sequence = ["Power On", "Water Flow", "Electrolysis Start", "Hydrogen Purge"]
var command_index = 0

# Bubble scene to spawn
var BubbleScene = preload("res://minigames/elektron/Bubble.tscn")

# Node references using @onready
@onready var oxygen_bar = $OxygenStatus/OxygenLevel
@onready var instructions_label = $InstructionsPanel/InstructionsLabel
@onready var bubble_timer = $BubbleTimer
@onready var bubble_container = $BubbleSection/BubbleContainer
@onready var release_pressure_button = $BubbleSection/ReleasePressureButton
@onready var liquid_slot = $LiquidUnitSection/LiquidUnitSlot
@onready var liquid_unit = $LiquidUnitSection/NewLiquidUnit

# Track if the minigame is completed
var minigame_completed = false

func _ready():
	oxygen_level = max_oxygen
	oxygen_bar.value = oxygen_level

	if Engine.has_singleton("GameState"):
		var game_state = Engine.get_singleton("GameState")
		if game_state.get_system_status("oxygen"):
			minigame_completed = true
			instructions_label.text = "Oxygen system is functional.\nPress 'E' to return to ship."
			oxygen_bar.modulate = Color(0.5, 1.0, 0.5)

	if release_pressure_button:
		release_pressure_button.disabled = true

	clear_bubbles()

	$GasAnalyzerPanel/ScanButton.pressed.connect(_on_scan_pressed)
	release_pressure_button.pressed.connect(_on_pressure_release)
	liquid_slot.area_entered.connect(_on_liquid_slot_area_entered)

	var command_row = $CommandSection/CommandButtonRow
	for button in command_row.get_children():
		if button is Button:
			var button_text = button.text
			if button_text.is_empty():
				if button.name == "PowerOn": button_text = "Power On"
				elif button.name == "WaterFlow": button_text = "Water Flow"
				elif button.name == "Electrolysis": button_text = "Electrolysis Start"
				elif button.name == "HydrogenPurge": button_text = "Hydrogen Purge"
			button.pressed.connect(_on_command_button.bind(button_text))

	# Educational intro
	if liquid_unit_damaged and not minigame_completed:
		instructions_label.text = "Welcome astronaut! Our oxygen machine, called the Elektron, needs fixing. It uses water to make oxygen by splitting it into hydrogen and oxygen gases. Let's repair it to keep breathing!"

func _process(delta):
	if visible and not minigame_completed:
		var repair_skill = astronaut.repair_skill if astronaut else 1.0
		var drain_multiplier = 1.0 / repair_skill
		oxygen_level -= delta * 5 * drain_multiplier #change this code to deplete faster
		oxygen_bar.value = oxygen_level

		if oxygen_level < warning_threshold:
			is_oxygen_critical = true
		else:
			is_oxygen_critical = false

		if oxygen_level <= 0:
			game_over("Oxygen depleted! Mission failed.")

func _spawn_bubbles(count := 3):
	for i in range(count):
		var bubble = BubbleScene.instantiate()
		bubble.position = Vector2(randf_range(20, 180), randf_range(20, 60))
		bubble_container.add_child(bubble)
		if bubble.has_method("play"):
			bubble.play("float")

func clear_bubbles():
	for bubble in bubble_container.get_children():
		bubble.queue_free()

# PHASE 1: Detect the Problem
func _on_scan_pressed():
	if minigame_completed:
		instructions_label.text = "System is working. Press 'E' to return."
		return

	bubbles_present = true
	instructions_label.text = "Warning: Gas bubbles found! When water splits into gases, bubbles can block the machine and slow down oxygen making. We must release pressure to clear them!"
	_spawn_bubbles(5)
	release_pressure_button.disabled = false

# PHASE 2: Clear the Gas Bubbles
func _on_pressure_release():
	if minigame_completed:
		return
	if bubbles_present:
		bubbles_present = false
		clear_bubbles()
		release_pressure_button.disabled = true
		if liquid_unit_damaged:
			instructions_label.text = "Bubbles cleared! Great job. Now, we should check the liquid unit — it stores the water the Elektron needs for splitting into oxygen and hydrogen."
		else:
			instructions_label.text = "Bubbles cleared. Good job!"
	else:
		instructions_label.text = "No bubbles were stuck! The system is staying strong for now."

# PHASE 3: Swap the Liquid Unit
func _on_liquid_slot_area_entered(area):
	if minigame_completed:
		return
	if area.name == "NewLiquidUnit":
		liquid_unit_damaged = false
		GameState.set_resource_amount("oxygen_tanks", GameState.get_resource_amount("oxygen_tanks") - 1)
		area.visible = false
		instructions_label.text = "New liquid unit installed! Clean water is ready for splitting into oxygen and hydrogen. Now let's restart the machine the right way to stay safe!"

# PHASE 4: Restart System
func _on_command_button(command):
	if minigame_completed:
		instructions_label.text = "System already fixed! Press 'E' to return."
		return

	if command == command_sequence[command_index]:
		command_index += 1
		instructions_label.text = "%s complete! This step helps turn water into breathable oxygen." % command
		if command_index == command_sequence.size():
			minigame_completed = true
			complete_minigame("All steps complete. Oxygen system restored!")
	else:
		command_index = 0
		instructions_label.text = "Oops! That was the wrong step. Start again with 'Power On'."

# END STATES
func complete_minigame(message: String):
	instructions_label.text = message + "\nPress 'E' to return."
	minigame_completed = true
	GameState.set_system_status("oxygen", true)
	if Task_Manager != null:
		Task_Manager.task_done()
	if oxygen_bar:
		oxygen_bar.modulate = Color(0.5, 1.0, 0.5)

func set_task_manager(task_manager):
	Task_Manager = task_manager

func game_success(message: String):
	complete_minigame(message)


func _input(event):
	if not visible:
		return  # Don't handle input if this minigame isn't the active view

	if event.is_action_pressed("interact") and minigame_completed:
		get_tree().change_scene_to_file("res://SpaceTravel/SpaceTravel.tscn")

func game_over(message: String):
	instructions_label.text = message + "\n\nPress 'Restart' to try again."
	
	# Store the current scene path before changing scenes
	get_tree().set_meta("last_scene", "res://minigames/elektron/elektron_minigame.tscn")
	
	get_tree().change_scene_to_file("res://GameOver/game_over.tscn")

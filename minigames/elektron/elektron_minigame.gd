
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

var minigame_completed = false
var minigame_started := false
var timer_paused := false

var command_sequence = ["Power On", "Water Flow", "Electrolysis Start", "Hydrogen Purge"]
var command_index = 0

var BubbleScene = preload("res://minigames/elektron/Bubble.tscn")

@onready var oxygen_bar = $OxygenStatus/OxygenLevel
@onready var instructions_label = $InstructionsPanel/InstructionsLabel
@onready var bubble_container = $BubbleSection/BubbleContainer
@onready var release_pressure_button = $BubbleSection/ReleasePressureButton
@onready var liquid_slot = $LiquidUnitSection/LiquidUnitSlot
@onready var liquid_unit = $LiquidUnitSection/NewLiquidUnit
@onready var read_button = $InstructionsPanel/StopAndReadButton

func _ready():	
	oxygen_level = max_oxygen
	oxygen_bar.value = oxygen_level

	if Engine.has_singleton("GameState"):
		var game_state = Engine.get_singleton("GameState")
		if game_state.get_system_status("oxygen"):
			minigame_completed = true
			instructions_label.text = "Oxygen system is functional.\nPress 'E' to return to ship."
			oxygen_bar.modulate = Color(0.5, 1.0, 0.5)

	release_pressure_button.disabled = true
	clear_bubbles()

	$GasAnalyzerPanel/ScanButton.pressed.connect(_on_scan_pressed)
	release_pressure_button.pressed.connect(_on_pressure_release)
	liquid_slot.area_entered.connect(_on_liquid_slot_area_entered)
	read_button.pressed.connect(_on_read_button_pressed)

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

	if liquid_unit_damaged and not minigame_completed:
		instructions_label.text = "Welcome astronaut! The Elektron turns water into oxygen, but it's broken. Let’s fix it so we can breathe!\n\nClick Scan to begin — but watch out! Oxygen will start running out. Use 'Stop and Read' to pause and learn what each step means. Click it again to continue."

func _process(delta):
	if visible and minigame_started and not timer_paused and not minigame_completed:
		var repair_skill = astronaut.repair_skill if astronaut else 1.0
		var drain_multiplier = 1.0 / repair_skill
		oxygen_level -= delta * 3 * drain_multiplier
		oxygen_bar.value = oxygen_level

		if oxygen_level < warning_threshold:
			is_oxygen_critical = true
		else:
			is_oxygen_critical = false

		if oxygen_level <= 0:
			game_over("Oxygen depleted! Mission failed.")

func _on_read_button_pressed():
	timer_paused = !timer_paused
	read_button.text = "Continue" if timer_paused else "Stop and Read"

func _on_scan_pressed():
	if minigame_completed:
		instructions_label.text = "System is working. Press 'E' to return."
		return

	minigame_started = true
	bubbles_present = true
	instructions_label.text = "Warning: Gas bubbles found! When water splits into gases, bubbles can block the machine and slow down oxygen making. We must release pressure to clear them!"
	_spawn_bubbles(5)
	release_pressure_button.disabled = false

func _on_pressure_release():
	if minigame_completed:
		return
	if bubbles_present:
		bubbles_present = false
		clear_bubbles()
		release_pressure_button.disabled = true
		if liquid_unit_damaged:
			instructions_label.text = "Bubbles cleared! Now lets replace the liquid unit which stores the water the Elektron needs."
		else:
			instructions_label.text = "Bubbles cleared!"
	else:
		instructions_label.text = "No bubbles were found!"

func _on_liquid_slot_area_entered(area):
	if minigame_completed:
		return
	if area.name == "NewLiquidUnit":
		liquid_unit_damaged = false
		GameState.set_resource_amount("oxygen_tanks", GameState.get_resource_amount("oxygen_tanks") - 1)
		area.visible = false
		instructions_label.text = "Liquid unit installed! Let's restart the machine. Click Power On"

func _on_command_button(command):
	if minigame_completed:
		instructions_label.text = "System already fixed! Press 'E' to return."
		return

	if command == command_sequence[command_index]:
		command_index += 1
		match command:
			"Power On":
				instructions_label.text = "✅ Power is ON! The Elektron system is now awake and ready to fix our oxygen problem. Next let's ensure proper Water Flow"
			"Water Flow":
				instructions_label.text = "✅ Water is now flowing through the machine. We need water to make oxygen! Next let's begin the process of splitting Hydrogen and Oxygen molecules through Electrolysis"
			"Electrolysis Start":
				instructions_label.text = "✅ Electrolysis started! This step splits water into two gases: oxygen (for us) and hydrogen (which we don’t need). We can now get rid of the hydrogen through Hydrogen Purge"
			"Hydrogen Purge":
				instructions_label.text = "✅ Hydrogen is being purged! We're removing the extra hydrogen so only safe oxygen stays."

		if command_index == command_sequence.size():
			minigame_completed = true
			complete_minigame("✅ Hydrogen is being purged! We're removing the extra hydrogen so only safe oxygen stays. \n\nAll steps complete. Oxygen system restored!")
	else:
		command_index = 0
		instructions_label.text = "Oops! Wrong step. Start again with 'Power On'."

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

func complete_minigame(message: String):
	instructions_label.text = message + "\n\nPress 'E' to return."
	minigame_completed = true
	GameState.set_system_status("oxygen", true)
	if Task_Manager != null:
		Task_Manager.task_done()
	oxygen_bar.modulate = Color(0.5, 1.0, 0.5)

func game_over(message: String):
	instructions_label.text = message + "\n\nPress 'Restart' to try again."
	get_tree().set_meta("last_scene", "res://minigames/elektron/elektron_minigame.tscn")
	get_tree().change_scene_to_file("res://GameOver/game_over.tscn")

func set_task_manager(task_manager):
	Task_Manager = task_manager

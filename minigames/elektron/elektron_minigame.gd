extends Control
# Oxygen system settings
@export var max_oxygen: int = 100
var oxygen_level: float
var bubbles_present: bool = false
var liquid_unit_damaged: bool = true
# Restart sequence logic
var command_sequence = ["Power On", "Water Flow", "Electrolysis Start", "Hydrogen Purge"]
var command_index = 0
# Bubble scene to spawn
var BubbleScene = preload("res://Bubble.tscn")  # <- replace with your actual path
# Node references using @onready
@onready var oxygen_bar = $OxygenStatus/OxygenLevel
@onready var instructions_label = $InstructionsLabel
@onready var bubble_timer = $BubbleTimer
@onready var bubble_container = $BubbleSection/BubbleContainer
@onready var release_pressure_button = $BubbleSection/ReleasePressureButton
@onready var liquid_slot = $LiquidUnitSection/LiquidUnitSlot

func _ready():
	oxygen_level = max_oxygen
	oxygen_bar.value = oxygen_level
	
	# Add null checks for node references
	if release_pressure_button:
		release_pressure_button.disabled = true
	
	clear_bubbles()
	
	# Connect signals with null checks
	if $GasAnalyzerPanel/ScanButton:
		$GasAnalyzerPanel/ScanButton.pressed.connect(_on_scan_pressed)
	
	if release_pressure_button:
		release_pressure_button.pressed.connect(_on_pressure_release)
	
	if bubble_timer:
		bubble_timer.timeout.connect(_on_bubble_timer_timeout)
	
	if liquid_slot:
		liquid_slot.body_entered.connect(_on_liquid_unit_replaced)
	
	# Connect command buttons
	for button in $CommandSection.get_children():
		if button is Button:
			button.pressed.connect(_on_command_button.bind(button.text))
	
	if liquid_unit_damaged:
		instructions_label.text = "Liquid unit appears damaged. Start by scanning the system."

func _process(delta):
	if oxygen_level > 0:
		oxygen_level -= delta * 0.5
		oxygen_bar.value = oxygen_level
	else:
		game_over("Oxygen depleted! Mission failed.")

# --- BUBBLE MANAGEMENT ---
func _spawn_bubbles(count := 3):
	if bubble_container:
		for i in range(count):
			var bubble = BubbleScene.instantiate()
			bubble.position = Vector2(randf_range(40, 200), randf_range(0, 80))
			bubble_container.add_child(bubble)
			if bubble.has_method("play"):
				bubble.play("float")

func clear_bubbles():
	if bubble_container:
		for bubble in bubble_container.get_children():
			bubble.queue_free()

# --- PHASE 1: Detect the Problem ---
func _on_scan_pressed():
	if randi() % 2 == 0:
		bubbles_present = true
		instructions_label.text = "Gas bubbles detected! Release pressure."
		_spawn_bubbles()
		if release_pressure_button:
			release_pressure_button.disabled = false
	else:
		instructions_label.text = "No issues detected. System looks stable."

# --- PHASE 2: Clear the Gas Bubbles ---
func _on_pressure_release():
	if bubbles_present:
		bubbles_present = false
		print("Clearing bubbles - number of bubbles:", bubble_container.get_child_count())
		clear_bubbles()
		print("After clearing - number of bubbles:", bubble_container.get_child_count())

		if release_pressure_button:
			release_pressure_button.disabled = true
		instructions_label.text = "Bubbles cleared. Monitor system."
		
		if liquid_unit_damaged:
			instructions_label.text += " Liquid unit needs replacement."
	else:
		instructions_label.text = "No bubbles to release."

func _on_bubble_timer_timeout():
	bubbles_present = true
	_spawn_bubbles()
	if release_pressure_button:
		release_pressure_button.disabled = false
	instructions_label.text = "New gas bubbles forming! Act quickly."

# --- PHASE 3: Swap the Liquid Unit ---
func _on_liquid_unit_replaced(body):
	if body.name == "NewLiquidUnit":
		liquid_unit_damaged = false
		body.queue_free()
		instructions_label.text = "Liquid unit replaced successfully. Proceed to restart system."

# --- PHASE 4: Restart System ---
func _on_command_button(command):
	if command == command_sequence[command_index]:
		command_index += 1
		instructions_label.text = "Step completed: %s" % command
		if command_index == command_sequence.size():
			game_success("Elektron system restored. Oxygen stabilized.")
	else:
		command_index = 0
		instructions_label.text = "Incorrect sequence! Restart from 'Power On'."

# --- END STATES ---
func game_success(message: String):
	print(message)
	get_tree().change_scene_to_file("res://main_game_scene.tscn")

func game_over(message: String):
	print(message)
	get_tree().change_scene_to_file("res://game_over_scene.tscn")

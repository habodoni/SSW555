extends Control
@export var astronaut: Node

# Oxygen system settings
@export var max_oxygen: int = 100
var oxygen_level: float
var bubbles_present: bool = false
var liquid_unit_damaged: bool = true
var is_oxygen_critical: bool = false
var warning_threshold := 90.0
# Restart sequence logic
var command_sequence = ["Power On", "Water Flow", "Electrolysis Start", "Hydrogen Purge"]
var command_index = 0
# Bubble scene to spawn
var BubbleScene = preload("res://minigames/elektron/Bubble.tscn")  # Make sure this path is correct!
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
	
	print("ElektronMinigame: _ready function called")
	
	# Check if the oxygen system is already repaired
	if Engine.has_singleton("GameState"):
		var game_state = Engine.get_singleton("GameState")
		if game_state.get_system_status("oxygen"):
			# System is already repaired
			minigame_completed = true
			instructions_label.text = "Oxygen system is functional.\nPress 'E' to return to ship."
			if oxygen_bar:
				oxygen_bar.modulate = Color(0.5, 1.0, 0.5)  # Green tint to indicate success
	
	# Add null checks for node references
	if release_pressure_button:
		release_pressure_button.disabled = true
		print("Release pressure button found and disabled")
	else:
		print("Release pressure button not found!")
	
	clear_bubbles()
	
	# Connect signals with null checks
	if $GasAnalyzerPanel/ScanButton:
		$GasAnalyzerPanel/ScanButton.pressed.connect(_on_scan_pressed)
		print("Scan button connected")
	else:
		print("Scan button not found!")
	
	if release_pressure_button:
		release_pressure_button.pressed.connect(_on_pressure_release)
		print("Release pressure button connected")
	
	# Setup drag and drop for liquid unit
	if liquid_slot:
		# Connect to area_entered signal for Area2D interactions
		liquid_slot.area_entered.connect(_on_liquid_slot_area_entered)
		print("Liquid slot area_entered signal connected")
	else:
		print("Liquid slot not found!")
	
	# FIX: Connect command buttons from CommandButtonRow
	var command_row = $CommandSection/CommandButtonRow
	if command_row:
		print("Found CommandButtonRow, connecting buttons...")
		for button in command_row.get_children():
			if button is Button:
				# Get the button text which might not match the node name
				var button_text = button.text
				# If button text is empty, use the node name (but format it properly)
				if button_text.is_empty():
					if button.name == "PowerOn":
						button_text = "Power On"
					elif button.name == "WaterFlow":
						button_text = "Water Flow"
					elif button.name == "Electrolysis":
						button_text = "Electrolysis Start"
					elif button.name == "HydrogenPurge":
						button_text = "Hydrogen Purge"
				
				print("Connecting button: ", button.name, " with text: ", button_text)
				button.pressed.connect(_on_command_button.bind(button_text))
		print("Command buttons connected from CommandButtonRow")
	else:
		print("CommandButtonRow not found! Looking for direct children...")
		# Fallback to the old structure if the new one isn't found
		for button in $CommandSection.get_children():
			if button is Button:
				print("Connecting direct child button: ", button.name)
				button.pressed.connect(_on_command_button.bind(button.text))
		print("Attempted to connect direct child buttons")
	
	if liquid_unit_damaged and not minigame_completed:
		instructions_label.text = "Liquid unit appears damaged. Start by scanning the system."

func _process(delta):
	if visible: # minigame only runs when visible
		if oxygen_level > 0 and not minigame_completed:
			# Get repair_skill from the assigned astronaut node
			var repair_skill = astronaut.repair_skill if astronaut else 1.0
			var drain_multiplier = 1.0 / repair_skill
			oxygen_level -= delta * 0.5 * drain_multiplier
			oxygen_bar.value = oxygen_level

			if oxygen_level < warning_threshold:
				if not is_oxygen_critical:
					print("🚨 Oxygen critical! Level = ", oxygen_level)
				is_oxygen_critical = true
			else:
				is_oxygen_critical = false

		elif not minigame_completed and oxygen_level <= 0:
			game_over("Oxygen depleted! Mission failed.")


# --- BUBBLE MANAGEMENT ---
func _spawn_bubbles(count := 3):
	if bubble_container:
		print("Spawning " + str(count) + " bubbles")
		for i in range(count):
			var bubble = BubbleScene.instantiate()
			if bubble:
				# Use random positions within the container
				bubble.position = Vector2(randf_range(20, 180), randf_range(20, 60))
				bubble_container.add_child(bubble)
				
				# Try different methods to start animation
				if bubble.has_method("play"):
					bubble.play("float")
				elif bubble.has_node("AnimatedSprite2D"):
					var sprite = bubble.get_node("AnimatedSprite2D")
					if sprite and sprite.has_method("play"):
						sprite.play("float")
				
				print("Bubble added at position: ", bubble.position)
			else:
				print("Failed to instantiate bubble")
	else:
		print("Bubble container is null!")

func clear_bubbles():
	if bubble_container:
		print("Clearing bubbles, count before: ", bubble_container.get_child_count())
		for bubble in bubble_container.get_children():
			bubble.queue_free()
		print("Bubbles cleared, count after: ", bubble_container.get_child_count())
	else:
		print("Bubble container is null when clearing!")

# --- PHASE 1: Detect the Problem ---
func _on_scan_pressed():
	if minigame_completed:
		instructions_label.text = "System is functioning correctly.\nPress 'E' to return to ship."
		return
		
	print("Scan button pressed")
	# Always spawn bubbles when scan is pressed
	bubbles_present = true
	instructions_label.text = "Gas bubbles detected! Release pressure."
	_spawn_bubbles(5)
	if release_pressure_button:
		release_pressure_button.disabled = false
		print("Release pressure button enabled")

# --- PHASE 2: Clear the Gas Bubbles ---
func _on_pressure_release():
	if minigame_completed:
		return
		
	print("Pressure release button pressed")
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

# Keep this function definition but we won't connect it
func _on_bubble_timer_timeout():
	if minigame_completed:
		return
		
	print("Bubble timer timeout")
	bubbles_present = true
	_spawn_bubbles(3)
	if release_pressure_button:
		release_pressure_button.disabled = false
	instructions_label.text = "New gas bubbles forming! Act quickly."

# --- PHASE 3: Swap the Liquid Unit ---
# This is called when the NewLiquidUnit enters the LiquidUnitSlot area
func _on_liquid_slot_area_entered(area):
	if minigame_completed:
		return
		
	print("Area entered liquid slot: ", area.name)
	if area.name == "NewLiquidUnit":
		print("NewLiquidUnit placed in slot!")
		liquid_unit_damaged = false
		
		GameState.set_resource_amount("oxygen_tanks", GameState.get_resource_amount("oxygen_tanks") - 1)
		# Optional: you can queue_free the liquid unit here or just hide it
		# area.queue_free()
		area.visible = false
		instructions_label.text = "Liquid unit replaced successfully. Proceed to restart system."

# Legacy function, can be removed
func _on_liquid_unit_replaced(body):
	if minigame_completed:
		return
		
	print("Body entered: ", body.name)
	if body.name == "NewLiquidUnit":
		liquid_unit_damaged = false
		body.queue_free()
		instructions_label.text = "Liquid unit replaced successfully. Proceed to restart system."

# --- PHASE 4: Restart System ---
func _on_command_button(command):
	if minigame_completed:
		instructions_label.text = "System is already functional.\nPress 'E' to return to ship."
		return
		
	print("Command button pressed: ", command)
	print("Current command index: ", command_index)
	print("Expecting command: ", command_sequence[command_index])
	
	if command == command_sequence[command_index]:
		command_index += 1
		instructions_label.text = "Step completed: %s" % command
		print("Correct command! New index: ", command_index)
		if command_index == command_sequence.size():
			minigame_completed = true
			complete_minigame("Elektron system restored. Oxygen stabilized.")
	else:
		command_index = 0
		instructions_label.text = "Incorrect sequence! Restart from 'Power On'."
		print("Incorrect command! Sequence reset.")

# --- END STATES ---
func complete_minigame(message: String):
	print(message)
	instructions_label.text = message + "\nPress 'E' to return to ship."
	
	# Stop oxygen depletion
	minigame_completed = true
	
	# Update the game state to mark oxygen system as functional
	#if Engine.has_singleton("GameState"):
		#var game_state = Engine.get_singleton("GameState")
		#game_state.set_system_status("oxygen", true)
		#print("Oxygen system status updated in GameState")
	
	#get_singleton wasn't recognizing GameState so changed the code
	
	GameState.set_system_status("oxygen", true)
	
	# Optional: Update UI to show game is complete
	if oxygen_bar:
		oxygen_bar.modulate = Color(0.5, 1.0, 0.5)  # Green tint to indicate success

func game_success(message: String):
	print(message)
	# Instead of changing scenes, we now mark the game as complete
	complete_minigame(message)

func game_over(message: String):
	print(message)
	instructions_label.text = message + "\n\nPress 'E' to try again."

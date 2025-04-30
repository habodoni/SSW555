extends Control

  # This will be injected manually during testing

# Dictionary to track status of all systems
var system_status = {
	"oxygen": false,
	"navigation": false,
	# Add more systems as you create them
}

var task_manager = null

# Node references
@onready var oxygen_indicator = $StatusGrid/OxygenIndicator
@onready var navigation_indicator = $StatusGrid/NavigationIndicator
@onready var instruction_label = $InstructionLabel  # Add this label to your scene
@onready var button = $SystemDiagnosticsBackground/SendUpdatesButton

# Colors for indicators
var color_functional = Color(0.2, 0.8, 0.2)  # Green
var color_nonfunctional = Color(0.8, 0.2, 0.2)  # Red

func _ready():
	# Load saved system status from global game state
	load_system_status()
	
	# Update the UI based on loaded data
	update_ui()
	
	button.pressed.connect(send_updates)
	
	# Set instruction text
	if instruction_label:
		instruction_label.text = "Press 'E' to return to ship"

func _process(delta):
	# Check for 'E' key press to exit
	#if Input.is_action_just_pressed("interact"):
		#return_to_main_game()
		
	#had to comment out because the E interaction already exists in space travel 
		#this was causing bugs
		
	if visible:
		load_system_status()
		update_ui()

var complete_status = {"oxygen": true, "navigation": true, "waste": true}

func send_updates():
	print("Update button pressed")
	print($FrequencyTuningPanel2.is_locked)
	if($FrequencyTuningPanel2.is_locked):
		print("Update sent")
		if(GameState.system_status == complete_status):
			task_manager.task_done()

# Load system status from wherever you're storing game state
func load_system_status():
	# Check if GameState exists
	#if Engine.has_singleton("GameState"):
		#var game_state = Engine.get_singleton("GameState")
		#if game_state.has_method("get_system_status"):
			#system_status = game_state.get_system_status()
	#had to comment out because it wasn't able to find gamestate
	system_status = GameState.get_system_status()
	
	# For testing: you can enable this line to simulate completed repairs
	# system_status["oxygen"] = true
	
	#print("System status loaded: ", system_status)

# Update all UI elements based on current system status
func update_ui():
	# Update oxygen system indicator
	if oxygen_indicator:
		oxygen_indicator.color = color_functional if system_status["oxygen"] else color_nonfunctional
		#print("Oxygen indicator updated: ", system_status["oxygen"])
	#else:
		#print("Oxygen indicator not found!")
	
	# Update navigation system indicator
	if navigation_indicator:
		navigation_indicator.color = color_functional if system_status["navigation"] else color_nonfunctional
		#print("Navigation indicator updated: ", system_status["navigation"])
	#else:
		#print("Navigation indicator not found!")
	
	if navigation_indicator:
		$StatusGrid/WasteIndicator.color = color_functional if system_status["waste"] else color_nonfunctional
	
	# Add more systems as you implement them

func set_task_manager(manager):
	task_manager = manager

# Function to return to the main game
func return_to_main_game():
	print("Returning to main game...")
	
	# Find the parent that has the minigame_active property
	var parent = get_parent()
	while parent != null:
		if parent.has_method("set_minigame_active"):
			parent.set_minigame_active(false)
			print("Found parent with set_minigame_active method")
			return
		parent = parent.get_parent()
	
	# Fallback: If we couldn't find a parent with the method, just hide ourselves or change scene
	print("No parent with set_minigame_active method found, hiding diagnostics screen")
	hide()
	# Or change scene if needed
	# get_tree().change_scene_to_file("res://main_game_scene.tscn")

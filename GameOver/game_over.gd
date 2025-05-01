extends Control

# Keep track of which scene triggered the game over
var source_scene_path = ""

func _ready():
	$Panel/Button.pressed.connect(_on_restart)
	
	# Get the scene that triggered game over
	if get_tree().has_meta("last_scene"):
		source_scene_path = get_tree().get_meta("last_scene")
		print("Source scene path: ", source_scene_path)

func _on_restart():
	print("Restart button pressed") # Debug line
	
	if "elektron_minigame" in source_scene_path:
		print("Restarting elektron minigame") # Debug line
		get_tree().change_scene_to_file("res://minigames/elektron/elektron_minigame.tscn")
	else:
		print("Restarting main game") # Debug line
		get_tree().change_scene_to_file("res://SpaceTravel/SpaceTravel.tscn")
		GameState.set_system_status("waste", false)
		GameState.set_system_status("oxygen", false)
		GameState.set_system_status("navigation", false)

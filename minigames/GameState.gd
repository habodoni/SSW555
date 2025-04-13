extends Node

# Dictionary to track status of all systems
var system_status = {
	"oxygen": false,
	"navigation": false,
	# Add more systems as you create them
}

# Called when the node enters the scene tree for the first time
func _ready():
	pass

# Set a specific system's status
func set_system_status(system_name: String, is_functional: bool):
	if system_status.has(system_name):
		system_status[system_name] = is_functional
		print("System status updated - " + system_name + ": " + str(is_functional))
		# You could emit a signal here to notify other parts of the game
	else:
		print("Warning: Attempted to set status for unknown system: " + system_name)

# Get status of a specific system
func get_system_status(system_name: String = "") -> Variant:
	if system_name.is_empty():
		# Return the entire dictionary if no system specified
		return system_status
	elif system_status.has(system_name):
		return system_status[system_name]
	else:
		print("Warning: Attempted to get status for unknown system: " + system_name)
		return null

# Reset all system statuses (e.g., when starting a new game)
func reset_system_status():
	for key in system_status.keys():
		system_status[key] = false
	print("All system statuses reset to non-functional")

# Save game state to disk (implement if needed)
func save_game():
	# Example implementation using JSON
	var save_data = {
		"system_status": system_status
	}
	
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		print("Game saved successfully")
	else:
		print("Failed to save game")

# Load game state from disk (implement if needed)
func load_game() -> bool:
	if FileAccess.file_exists("user://savegame.json"):
		var file = FileAccess.open("user://savegame.json", FileAccess.READ)
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.get_data()
			if data.has("system_status"):
				system_status = data["system_status"]
				print("Game loaded successfully")
				return true
		
		print("Failed to parse save file")
	else:
		print("No save file found")
	
	return false

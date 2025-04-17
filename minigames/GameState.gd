extends Node

# Dictionary to track status of all systems
var system_status = {
	"oxygen": false,
	"navigation": false,
	# Add more systems as you create them
}

# Dictionary to track status of all resources
var resources = {
	"oxygen_tanks": 5,
	"fuel": 100,
	"max_oxygen_tanks": 5,
	"max_fuel": 100,
	"fuel_deplete_time": 100
	# Add more systems as you create them
}

var count = 0

# Called when the node enters the scene tree for the first time
func _ready():
	pass

func _process(delta: float) -> void:
	if (count == resources["fuel_deplete_time"] && resources["fuel"] != 0):
			count = 0
			resources["fuel"] = resources["fuel"] - 1
	else:
		count += 1


# Set a specific system's status
func set_system_status(system_name: String, is_functional: bool):
	if system_status.has(system_name):
		system_status[system_name] = is_functional
		print("System status updated - " + system_name + ": " + str(is_functional))
		# You could emit a signal here to notify other parts of the game
	else:
		print("Warning: Attempted to set status for unknown system: " + system_name)

# Set a specific system's status
func set_resource_amount(resource_name: String, amount: int):
	if resources.has(resource_name):
		resources[resource_name] = amount
		print("Resource updated - " + resource_name + ": " + str(amount))
		# You could emit a signal here to notify other parts of the game
	else:
		print("Warning: Attempted to set amount for unknown resource: " + resource_name)

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

# Get status of a specific system
func get_resource_amount(resource_name: String = "") -> Variant:
	if resource_name.is_empty():
		# Return the entire dictionary if no system specified
		return resources
	elif resources.has(resource_name):
		return resources[resource_name]
	else:
		print("Warning: Attempted to get amount for unknown resource: " + resource_name)
		return null

# Reset all system statuses (e.g., when starting a new game)
func reset_system_status():
	for key in system_status.keys():
		system_status[key] = false
	print("All system statuses reset to non-functional")

func set_resources_to_max():
	resources["oxygen_tanks"] = resources["oxygen_tanks_max"]
	resources["fuel"] = resources["fuel_max"]

# Save game state to disk (implement if needed)
func save_game():
	# Example implementation using JSON
	var save_data = {
		"system_status": system_status,
		"resources": resources
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

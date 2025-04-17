extends Node

# Existing mock system status for diagnostics
var mock_status = {
	"oxygen": true,
	"navigation": false
}

func get_system_status():
	return mock_status

# New mock inventory values for inventory tests
var resource_values = {
	"oxygen_tanks": 2,
	"max_oxygen_tanks": 5,
	"fuel": 70,
	"max_fuel": 100
}

func get_resource_amount(name: String) -> int:
	return resource_values.get(name, 0)

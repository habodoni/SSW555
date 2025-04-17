extends Node

@onready var inventory_label: Label = $Label  

func _ready():
	update_inventory_display()

func _process(delta):
	update_inventory_display()

func update_inventory_display():
	var current_tanks = GameState.get_resource_amount("oxygen_tanks")
	var max_tanks = GameState.get_resource_amount("max_oxygen_tanks")

	var current_fuel = GameState.get_resource_amount("fuel")
	var max_fuel = GameState.get_resource_amount("max_fuel")

	inventory_label.text = "Inventory:\n"
	inventory_label.text += "Oxygen Tanks: %d / %d\n" % [current_tanks, max_tanks]
	inventory_label.text += "Fuel: %d / %d" % [current_fuel, max_fuel]

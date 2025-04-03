extends Node

func _ready():
	print("✅ Running Elektron Minigame Tests...\n")
	var results = []

	results.append(test_scan_button())
	results.append(test_pressure_release())
	results.append(test_liquid_unit_replacement())
	results.append(test_correct_command_sequence())
	results.append(test_incorrect_command_sequence_resets())
	results.append(test_oxygen_drain_behavior())

	print("\n".join(results))
	print("\n✅ All ElektronMinigame tests completed.")
	get_tree().quit()

# ---------------------- ACTUAL UNIT TESTS ----------------------

# Tests scan button and bubbles 
func test_scan_button():
	var minigame = preload("res://minigames/elektron/elektron_minigame.tscn").instantiate()
	add_child(minigame)
	minigame._on_scan_pressed()

	assert(minigame.bubbles_present, "❌ bubbles_present should be true after scan.")
	assert(!minigame.release_pressure_button.disabled, "❌ Release button should be enabled after scan.")
	assert("Gas bubbles detected" in minigame.instructions_label.text, "❌ Instruction label incorrect after scan.")

	return "✅ test_scan_button passed"

# Tests the pressure release
func test_pressure_release():
	var minigame = preload("res://minigames/elektron/elektron_minigame.tscn").instantiate()
	add_child(minigame)
	minigame._on_scan_pressed()
	minigame._on_pressure_release()

	assert(!minigame.bubbles_present, "❌ Bubbles should be gone after pressure release.")
	assert(minigame.release_pressure_button.disabled, "❌ Release button should be disabled after use.")
	assert("Bubbles cleared" in minigame.instructions_label.text, "❌ Instruction not updated correctly.")

	return "✅ test_pressure_release passed"

# Tests replacing the liquid unit 
func test_liquid_unit_replacement():
	var minigame = preload("res://minigames/elektron/elektron_minigame.tscn").instantiate()
	add_child(minigame)

	var mock_area = Area2D.new()
	mock_area.name = "NewLiquidUnit"
	minigame._on_liquid_slot_area_entered(mock_area)

	assert(!minigame.liquid_unit_damaged, "❌ Liquid unit should be marked repaired.")
	assert(!mock_area.visible, "❌ Liquid unit should be hidden after placement.")
	assert("replaced successfully" in minigame.instructions_label.text, "❌ Instruction text incorrect.")

	return "✅ test_liquid_unit_replacement passed"

# Tests the corect command sequence
func test_correct_command_sequence():
	var minigame = preload("res://minigames/elektron/elektron_minigame.tscn").instantiate()
	add_child(minigame)

	for cmd in minigame.command_sequence:
		minigame._on_command_button(cmd)

	assert(minigame.command_index == minigame.command_sequence.size(), "❌ Command sequence should be completed.")

	return "✅ test_correct_command_sequence passed"

# Tests the incorrect command sequence 
func test_incorrect_command_sequence_resets():
	var minigame = preload("res://minigames/elektron/elektron_minigame.tscn").instantiate()
	add_child(minigame)

	minigame._on_command_button("Wrong Command")

	assert(minigame.command_index == 0, "❌ Command index should reset on wrong input.")

	return "✅ test_incorrect_command_sequence_resets passed"


# Tests the behavior of the Oxygen Drain 
func test_oxygen_drain_behavior():
	var minigame = preload("res://minigames/elektron/elektron_minigame.tscn").instantiate()

	# Add the mock astronaut here
	var MockAstronaut = preload("res://tests/mock_astronaut.gd")
	var astronaut = MockAstronaut.new()
	minigame.astronaut = astronaut

	add_child(minigame)

	var initial_oxygen = minigame.oxygen_level
	minigame._process(1.0)  # Simulate 1 second of game time

	assert(minigame.oxygen_level < initial_oxygen, "❌ Oxygen level should decrease after time.")

	return "✅ test_oxygen_drain_behavior passed"

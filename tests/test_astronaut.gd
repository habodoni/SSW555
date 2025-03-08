extends Node  # Root node for the test scene

var astronaut  # Instance of the Astronaut character
var output_label  # UI element for displaying test results

func _ready():
	"""
	Main function that runs all unit tests when the test scene starts.
	Uses assert statements for error handling.
	"""
	print("Running Astronaut Tests...")

	# Test Fixture: Initialize test objects
	output_label = $Label  # Find the Label node
	astronaut = CharacterBody2D.new()
	astronaut.set_script(load("res://Astronaut/Astronaut.gd"))  # Ensure the path is correct

	# Run all tests
	var results = []
	results.append(test_initial_speed())
	results.append(test_movement("left", Vector2(-astronaut.speed, 0)))
	results.append(test_movement("right", Vector2(astronaut.speed, 0)))
	results.append(test_movement("up", Vector2(0, -astronaut.speed)))
	results.append(test_movement("down", Vector2(0, astronaut.speed)))

	# Display results in the UI and console
	output_label.text = "\n".join(results)
	print("All tests completed.")

# ---------------------------- ACTUAL UNIT TESTS ----------------------------

func test_initial_speed():
	"""
	Test: Ensures that the Astronaut's initial speed is correct.
	"""
	var expected_speed = 400
	assert(astronaut.speed == expected_speed, "❌ Speed test failed! Expected: %d, Got: %d" % [expected_speed, astronaut.speed])
	return "✅ Speed test passed! Expected: %d, Got: %d" % [expected_speed, astronaut.speed]

func test_movement(direction, expected_velocity):
	"""
	Test: Ensures that pressing a movement key sets the correct velocity.
	Uses assert() to enforce expected results.
	"""
	Input.action_press(direction)  # Simulate key press
	astronaut.get_input()  # Update velocity
	Input.action_release(direction)  # Release the key

	var actual_velocity = astronaut.velocity
	assert(actual_velocity == expected_velocity, "❌ %s movement test failed! Expected: %s, Got: %s" % [direction.capitalize(), str(expected_velocity), str(actual_velocity)])
	
	return "✅ %s movement test passed! Velocity: %s" % [direction.capitalize(), str(actual_velocity)]

extends Node  # Test runner

var astronaut  # Astronaut instance
var output_label  # Label to display results

func _ready():
	"""
	Runs all unit tests when the test scene starts.
	"""
	print("Running Astronaut Unit Tests...\n")

	# ✅ Create a UI label to show results
	output_label = Label.new()
	output_label.text = "Running Astronaut Tests...\n"
	output_label.set("theme_override_colors/font_color", Color(1, 1, 1))  # White text
	output_label.set("theme_override_font_sizes/font_size", 16)  # Bigger font
	add_child(output_label)  # Add to scene

	# Create astronaut instance
	astronaut = CharacterBody2D.new()
	astronaut.set_script(load("res://Astronaut/Astronaut.gd"))  # Load the Astronaut script

	# Manually create HealthBar
	var health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	astronaut.add_child(health_bar)
	
	# Manually create AnimatedSprite2D with a placeholder animation
	var sprite = AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D"
	
	var frames = SpriteFrames.new()  # Create empty animation set
	
	# Remove existing animations to prevent duplicates
	for anim in frames.get_animation_names():
		frames.remove_animation(anim)
	
	# Check if animation already exists before adding
	var animations_to_add = ["default", "UpWalk", "DownWalk", "LeftWalk", "RightWalk"]
	for anim in animations_to_add:
		frames.add_animation(anim)
	
	sprite.sprite_frames = frames  # Attach it to the sprite
	astronaut.add_child(sprite)

	add_child(astronaut)  # Add astronaut to scene

	# Run all test cases
	var results = []
	results.append(test_initial_health())
	results.append(test_movement("left", Vector2(-astronaut.speed, 0)))
	results.append(test_movement("right", Vector2(astronaut.speed, 0)))
	results.append(test_movement("up", Vector2(0, -astronaut.speed)))
	results.append(test_movement("down", Vector2(0, astronaut.speed)))
	results.append(test_health_drain())
	results.append(test_health_recovery())

	# Display results in the UI
	output_label.text += "\n".join(results)
	output_label.text += "\nAll Astronaut tests completed.\n"

	print("\n".join(results))
	print("All Astronaut tests completed.\n")
	
	get_tree().quit() #Terminates run for CI.


# ---------------------- ACTUAL UNIT TESTS ----------------------

# Tests initial health of astronaut
func test_initial_health():
	var expected_health = astronaut.MAX_HEALTH
	assert(astronaut.health == expected_health, "❌ Initial health test failed! Expected: %d, Got: %d" % [expected_health, astronaut.health])
	return "✅ Initial health test passed!"

# Astronaut movement test
func test_movement(direction, expected_velocity):
	Input.action_press(direction)
	astronaut.get_input()
	Input.action_release(direction)

	var actual_velocity = astronaut.velocity
	assert(actual_velocity == expected_velocity, "❌ Movement test failed! Direction: %s | Expected: %s, Got: %s" % [direction, str(expected_velocity), str(actual_velocity)])
	return "✅ Movement test passed for direction: %s" % direction

# Tests health draining functionality
func test_health_drain():
	var initial_health = astronaut.health
	astronaut.drain_health(1.0)  # Simulate 1 second of drain
	var expected_health = max(initial_health - (astronaut.MAX_HEALTH / astronaut.drain_time), 0)
	
	assert(astronaut.health == expected_health, "❌ Health drain test failed! Expected: %f, Got: %f" % [expected_health, astronaut.health])
	return "✅ Health drain test passed!"

# Tests health recovery functionality
func test_health_recovery():
	var initial_health = 50  # Simulate astronaut at half health
	astronaut.health = initial_health
	astronaut.increase_health(20)

	var expected_health = min(initial_health + 20, astronaut.MAX_HEALTH)
	assert(astronaut.health == expected_health, "❌ Health recovery test failed! Expected: %d, Got: %d" % [expected_health, astronaut.health])
	return "✅ Health recovery test passed!"

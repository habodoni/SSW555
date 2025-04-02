extends Node  # Test runner

var astronaut  # Astronaut instance
var output_label  # Label to display results
var minigame_active = false # Expected node

func _ready():
	"""
	Runs all unit tests when the test scene starts.
	"""
	print("Running Astronaut Unit Tests...\n")

	# Create a UI label to show results
	output_label = Label.new()
	output_label.text = "Running Astronaut Tests...\n"
	output_label.set("theme_override_colors/font_color", Color(1, 1, 1))  # White text
	output_label.set("theme_override_font_sizes/font_size", 16)  # Bigger font
	add_child(output_label)  # Add to scene

	# Create astronaut instance
	var astronaut_scene = preload("res://Astronaut/Astronaut.tscn")  # Make sure this exists!
	astronaut = astronaut_scene.instantiate()

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
	results.append(test_multiple_astronauts())
	results.append(test_active_player_can_move())
	results.append(test_non_active_player_cannot_move())
	results.append(test_switching_mechanic())

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
	
# Tests that there is more than one astronaut 
func test_multiple_astronauts():
	var space_travel_scene = preload("res://SpaceTravel/SpaceTravel.tscn")  # ✅ Use the SCENE, not the script
	var space_travel = space_travel_scene.instantiate()
	add_child(space_travel)

	# _ready will be called automatically after add_child, but just in case
	if space_travel.has_method("_ready"):
		space_travel._ready()

	var astronaut_count = 0
	for child in space_travel.get_children():
		if child.has_method("is_player"):  # Simple check to identify astronaut
			astronaut_count += 1

	assert(astronaut_count > 1, "❌ Astronaut count test failed! Expected more than 1 astronaut, got: %d" % astronaut_count)
	return "✅ Astronaut count test passed!"

# Tests that an active player can move
func test_active_player_can_move():
	astronaut.setup(true, 0, 0)  # Set as active player
	astronaut.velocity = Vector2.ZERO
	Input.action_press("right")
	astronaut._physics_process(1.0)
	Input.action_release("right")

	var expected = Vector2(astronaut.speed, 0)
	assert(astronaut.velocity == expected, "❌ Active player move test failed! Expected: %s, Got: %s" % [expected, astronaut.velocity])
	return "✅ Active player movement test passed!"

# Tests that a non-active player cannot move
func test_non_active_player_cannot_move():
	astronaut.setup(false, 0, 0)  # Set as non-active
	astronaut.velocity = Vector2.ZERO  # Reset to ensure a clean test
	Input.action_press("right")
	astronaut._physics_process(1.0)  # Simulate 1 second of game logic
	Input.action_release("right")

	var expected = Vector2(0, 0)
	assert(astronaut.velocity == expected, "❌ Non-active player move test failed! Expected: %s, Got: %s" % [expected, astronaut.velocity])
	return "✅ Non-active player cannot move test passed!"
	
# Tests astronaut switching functionality
func test_switching_mechanic():
	var astronaut_scene = preload("res://Astronaut/Astronaut.tscn")

	# Instantiate two astronauts
	var astro1 = astronaut_scene.instantiate()
	var astro2 = astronaut_scene.instantiate()

	add_child(astro1)
	add_child(astro2)

	# Set initial active status
	astro1.set_active_player(true)
	astro2.set_active_player(false)

	# Grab the Area2D node from astro2
	var area2d = astro2.get_node("Area2D")
	area2d.player_near = true
	area2d.player = astro1  # Simulate astro1 being near the switch

	# Simulate pressing the switch key
	Input.action_press("Switch")
	area2d._process(0.016)  # Simulate one frame
	Input.action_release("Switch")

	# Assert switch happened
	assert(astro1.active_player == false and astro2.active_player == true,
		"❌ Astronaut switch mechanic failed! astro1 active: %s, astro2 active: %s" % [astro1.active_player, astro2.active_player])

	return "✅ Astronaut switch mechanic test passed!"

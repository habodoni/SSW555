extends Node  # Test runner

var apple  # Apple instance
var fake_player  # Simulated player character
var output_label  # UI label for results

func _ready():
	"""
	Runs all unit tests when the test scene starts.
	"""
	print("Running Apple Unit Tests...\n")

	# Create a UI label to show results
	output_label = Label.new()
	output_label.text = "Running Apple Tests...\n"
	add_child(output_label)  # Add to scene

	# Create an Apple instance for testing
	apple = Area2D.new()
	apple.set_script(load("res://MegaApple/apple.gd"))  # Load apple script
	add_child(apple)

	# Create a fake player (simulating CharacterBody2D)
	fake_player = CharacterBody2D.new()
	fake_player.set_script(load("res://Astronaut/Astronaut.gd"))  # Load astronaut script
	
	# Manually create a HealthBar for the fake player
	var health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	fake_player.add_child(health_bar) # Prevents errors
	
	# Manually create AnimatedSprite2D to prevent animation error
	var sprite = AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D"
	
	var frames = SpriteFrames.new()  # Create empty animation set
	var animations_to_add = ["default", "UpWalk", "DownWalk", "LeftWalk", "RightWalk"]
	for anim in animations_to_add:
		if not frames.has_animation(anim):  # Ensure no duplicates
			frames.add_animation(anim)  # Add necessary animations
		
	sprite.sprite_frames = frames # Attach animations to sprite
	fake_player.add_child(sprite)
	
	fake_player.health = 50  # Simulate player at 50 HP
	add_child(fake_player)

	# Run test cases
	var results = []
	results.append(await run_apple_test(test_apple_increases_health))
	results.append(await run_apple_test(test_apple_disappears_after_pickup))
	results.append(await run_apple_test(test_apple_ignores_non_players))

	# Display results in UI
	output_label.text += "\n".join(results)
	output_label.text += "\nAll Apple tests completed.\n"

	print("\n".join(results))
	print("All Apple tests completed.\n")

# ---------------------- Helper Function for Apple ----------------------

# Runs a test case and resets `apple` before each test.
func run_apple_test(test_function):
	apple = Area2D.new()
	apple.set_script(load("res://MegaApple/apple.gd"))  # Load apple script
	add_child(apple)  # Add new apple before each test
	
	return await test_function.call() 
	
# ---------------------- ACTUAL UNIT TESTS ----------------------

# Test 1: Ensures that the apple increases player's health.
func test_apple_increases_health():
	var initial_health = fake_player.health
	apple._on_body_entered(fake_player)  # Simulate player collecting the apple
	var expected_health = min(initial_health + apple.heal_amount, fake_player.MAX_HEALTH)

	assert(fake_player.health == expected_health, "❌ Health increase test failed! Expected: %d, Got: %d" % [expected_health, fake_player.health])
	return "✅ Health increase test passed!"

# Test 2: Ensures that the apple is removed after being picked up. 
func test_apple_disappears_after_pickup():
	var apple_reference = apple 
	
	var apple_exists_before = apple_reference.is_inside_tree()
	apple._on_body_entered(fake_player)  # Simulate pickup
	await get_tree().process_frame
	
	var apple_exists_after = is_instance_valid(apple_reference) # Check if apple instance is valid

	assert(apple_exists_before and not apple_exists_after, "❌ Apple removal test failed! Expected: Removed, Got: Still exists")
	return "✅ Apple removal test passed!"

# Test 3: Ensures that non-player objects cannot pick up the apple.
func test_apple_ignores_non_players():
	var non_player = Node2D.new()  # Create a non-player object
	add_child(non_player)

	var initial_health = fake_player.health
	apple._on_body_entered(non_player)  # Simulate non-player touching the apple

	assert(fake_player.health == initial_health, "❌ Apple pickup restriction test failed! Expected: %d, Got: %d" % [initial_health, fake_player.health])
	return "✅ Apple pickup restriction test passed!"

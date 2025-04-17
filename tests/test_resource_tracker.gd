extends Node

func _ready():
	print("🔧 Starting Resource Tracker Tests...\n")

	# Load and instance the inventory scene
	var inventory_scene = load("res://ResourceTracker/ResourceTracker.tscn") 
	var inventory_ui = inventory_scene.instantiate()

	# Inject GameState mock before _ready runs
	var mock_state = preload("res://tests/mock_game_state.gd").new()
	inventory_ui.GameState = mock_state

	# Add to tree to trigger _ready
	add_child(inventory_ui)

	await get_tree().create_timer(0.1).timeout

	run_display_test(inventory_ui)

	get_tree().quit()

func run_display_test(inventory_ui):
	var expected_text = "Inventory:\nOxygen Tanks: 2 / 5\nFuel: 70 / 100"
	var actual_text = inventory_ui.inventory_label.text.strip_edges()
	assert_test(actual_text == expected_text, "Inventory label text is accurate and formatted correctly.")

func assert_test(condition: bool, message: String):
	if condition:
		print("✅ PASS:", message)
	else:
		push_error("❌ FAIL: %s" % message)

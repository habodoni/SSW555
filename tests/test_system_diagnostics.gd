extends Node

func _ready():
	print("🔧 Starting system diagnostics tests...\n")

	# Load and instance the SystemDiagnostics scene
	var scene = load("res://SystemDiagnostics/system_diagnostics.tscn")  # <- Update this path!
	var diagnostics = scene.instantiate()

	# Inject mock GameState before adding to the tree
	var mock_state = preload("res://tests/mock_game_state.gd").new()
	diagnostics.GameState = mock_state

	# Add to the tree — now _ready() will run with GameState set
	add_child(diagnostics)

	# Delay a bit to let _ready() complete
	await get_tree().create_timer(0.1).timeout

	# Run tests
	test_instruction_text(diagnostics)
	test_status_loading(diagnostics)
	test_indicator_colors(diagnostics)
	test_return_to_main_game(diagnostics)

	print("\n✅ All tests completed!")
	get_tree().quit()


func test_instruction_text(diagnostics):
	var label = diagnostics.instruction_label
	assert(label.text == "Press 'E' to return to ship", "❌ Instruction label not set correctly.")
	print("✔ Instruction label test passed.")

func test_status_loading(diagnostics):
	var status = diagnostics.system_status
	assert(status["oxygen"] == true and status["navigation"] == false, "❌ System status did not load from GameState correctly.")
	print("✔ System status loading test passed.")

func test_indicator_colors(diagnostics):
	var expected_oxygen_color = diagnostics.color_functional
	var expected_nav_color = diagnostics.color_nonfunctional

	assert(diagnostics.oxygen_indicator.color == expected_oxygen_color, "❌ Oxygen indicator color incorrect.")
	assert(diagnostics.navigation_indicator.color == expected_nav_color, "❌ Navigation indicator color incorrect.")
	print("✔ Indicator color test passed.")

func test_return_to_main_game(diagnostics):
	diagnostics.return_to_main_game()
	assert(!diagnostics.visible, "❌ Diagnostics screen should be hidden after return_to_main_game fallback.")
	print("✔ Return to main game fallback test passed.")

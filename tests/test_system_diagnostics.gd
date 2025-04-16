extends Node

var diagnostics  # Instance of system_diagnostics.gd
var mock_game_state
var mock_parent

func _ready():
	print("Running System Diagnostics Tests...\n")

	# --------------------------------------
	# Create required child UI nodes
	# --------------------------------------
	var oxygen_indicator = ColorRect.new()
	oxygen_indicator.name = "OxygenIndicator"

	var navigation_indicator = ColorRect.new()
	navigation_indicator.name = "NavigationIndicator"

	var instruction_label = Label.new()
	instruction_label.name = "InstructionLabel"

	var status_grid = Node.new()
	status_grid.name = "StatusGrid"
	status_grid.add_child(oxygen_indicator)
	status_grid.add_child(navigation_indicator)

	# --------------------------------------
	# Create diagnostics and attach script
	# --------------------------------------
	diagnostics = Control.new()
	diagnostics.set_script(load("res://SystemDiagnostics/system_diagnostics.gd"))  
	diagnostics.add_child(status_grid)
	diagnostics.add_child(instruction_label)

	# --------------------------------------
	# Mock parent with set_minigame_active()
	# --------------------------------------
	mock_parent = preload("res://tests/mock_parent.gd").new()
	mock_parent.name = "MockParent"
	mock_parent.add_child(diagnostics)
	add_child(mock_parent)

	# --------------------------------------
	# Register mock GameState singleton
	# --------------------------------------
	mock_game_state = preload("res://tests/mock_game_state.gd").new()
	Engine.register_singleton("GameState", mock_game_state)

	# Wait a frame to ensure _ready() runs
	await get_tree().process_frame


# ---------------------- ACTUAL UNIT TESTS ----------------------

	var results = []
	results.append(await run_test(test_load_system_status))
	results.append(await run_test(test_update_ui_colors))
	results.append(await run_test(test_return_to_main_game))

	print("\n".join(results))
	get_tree().quit()


# ----------------------------------------
func run_test(test_func):
	return await test_func.call()

# ----------------------------------------
# Tests that GameState is read correctly
func test_load_system_status():
	mock_game_state.set_system_status({
		"oxygen": true,
		"navigation": false
	})

	diagnostics.load_system_status()

	assert(diagnostics.system_status["oxygen"] == true, "❌ Oxygen status not loaded correctly.")
	assert(diagnostics.system_status["navigation"] == false, "❌ Navigation status not loaded correctly.")

	return "✅ load_system_status test passed!"

# ----------------------------------------
# Tests that indicator colors match status
func test_update_ui_colors():
	diagnostics.system_status = {
		"oxygen": true,
		"navigation": false
	}

	diagnostics.update_ui()

	var oxygen = diagnostics.get_node("StatusGrid/OxygenIndicator")
	var navigation = diagnostics.get_node("StatusGrid/NavigationIndicator")

	assert(oxygen.color == diagnostics.color_functional, "❌ Oxygen indicator not green when functional.")
	assert(navigation.color == diagnostics.color_nonfunctional, "❌ Navigation indicator not red when nonfunctional.")

	return "✅ update_ui test passed!"

# ----------------------------------------
# Tests that diagnostics calls set_minigame_active()
func test_return_to_main_game():
	print("Before call: mock_parent.minigame_active =", mock_parent.minigame_active)
	diagnostics.return_to_main_game()
	await get_tree().process_frame
	print("After call: mock_parent.minigame_active =", mock_parent.minigame_active)

	assert(mock_parent.minigame_active == false, "❌ return_to_main_game didn't update minigame_active.")
	return "✅ return_to_main_game test passed!"

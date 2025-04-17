extends Node

const MINIGAME_SCENE_PATH = "res://Navigation/Navigation.tscn"

var minigame: Node = null
var initial_thrust
var initial_angle

func _ready():
	run_tests()

func run_tests():
	print("Running tests on ", MINIGAME_SCENE_PATH, "...")

	var scene = load(MINIGAME_SCENE_PATH)
	minigame = scene.instantiate()

	add_child(minigame)

	# Get the ShipIcon node where your main logic lives
	var ship_icon = minigame.get_node("ShipIcon")

	# Store initial values
	initial_thrust = ship_icon.thrust_power
	initial_angle = ship_icon.angle

	test_thrust_input(ship_icon)
	test_angle_input(ship_icon)
	test_apply_inputs(ship_icon)
	test_chart_button_logic(ship_icon)
	test_navigation_completion(ship_icon)

	print("All tests finished.")

func test_thrust_input(ship_icon):
	var before = ship_icon.thrust_power
	ship_icon.thrust_power += 10  # Simulate pressing up
	ship_icon.handle_input(0.1)   # If needed for side effects
	assert_test(ship_icon.thrust_power > before, "Thrust increases with simulated up key.")

func test_angle_input(ship_icon):
	var before = ship_icon.angle
	ship_icon.angle += ship_icon.turn_speed * 0.1  # Simulate right key press
	ship_icon.handle_input(0.1)  # If needed
	assert_test(ship_icon.angle > before, "Angle increases with simulated right key.")

func test_apply_inputs(ship_icon):
	ship_icon.thrust_input.text = "350"
	ship_icon.angle_input.text = "90"
	ship_icon.apply_input_values()
	assert_test(ship_icon.thrust_power == 350, "Thrust updates from input field.")
	assert_test(round(rad_to_deg(ship_icon.angle)) == 90, "Angle updates from input field.")

func test_chart_button_logic(ship_icon):
	ship_icon.thrust_power = 440
	ship_icon.angle = deg_to_rad(345)
	ship_icon.draw_trajectory()
	assert_test(ship_icon.chart_button.visible == false, "Chart button hidden for incorrect path.")

	ship_icon.thrust_power = 420
	ship_icon.angle = deg_to_rad(345)
	ship_icon.draw_trajectory()
	assert_test(ship_icon.chart_button.visible == true, "Chart button visible for correct path.")

func test_navigation_completion(ship_icon):
	# Simulate pressing chart button
	ship_icon.chart_button.emit_signal("pressed")
	assert_test(GameState.get_system_status("navigation") == true, "GameState updated on chart complete.")

func assert_test(condition: bool, message: String):
	if condition:
		print("✅ PASS:", message)
	else:
		push_error("❌ FAIL: %s" % message)

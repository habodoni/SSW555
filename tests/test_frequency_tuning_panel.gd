extends Node

var panel: Control

func _ready():
	print("🚀 Running FrequencyTuningPanel tests...")
	var scene = load("res://minigames/FrequencyTuningPanel.tscn")
	panel = scene.instantiate()
	add_child(panel)

	await get_tree().process_frame  # Wait a frame so _ready runs

	test_nodes_assigned()
	test_target_frequency_range()
	test_slider_initial_offset()
	test_locking_logic()
	test_ui_updates()
	print("✅ All FrequencyTuningPanel tests completed!")

func test_nodes_assigned():
	assert(panel.target_label != null, "target_label not assigned")
	assert(panel.player_label != null, "player_label not assigned")
	assert(panel.slider != null, "slider not assigned")
	assert(panel.status_label != null, "status_label not assigned")
	assert(panel.target_wave != null, "target_wave not assigned")
	assert(panel.player_wave != null, "player_wave not assigned")
	print("✅ test_nodes_assigned passed")

func test_target_frequency_range():
	assert(panel.target_frequency >= 2.0 and panel.target_frequency <= 5.0, 
		"target_frequency out of range")
	print("✅ test_target_frequency_range passed")

func test_slider_initial_offset():
	var diff = abs(panel.slider.value - panel.target_frequency)
	assert(diff >= 0.5, "slider initial offset too small (<0.5 Hz)")
	print("✅ test_slider_initial_offset passed")

func test_locking_logic():
	panel.slider.value = panel.target_frequency
	panel._process(0.016)
	assert(panel.is_locked == true, "should be locked when frequencies match")
	assert("Locked" in panel.status_label.text, "status label should show locked")

	panel.slider.value = panel.target_frequency + 0.3
	panel._process(0.016)
	assert(panel.is_locked == false, "should not be locked with small offset")
	assert("Almost" in panel.status_label.text, "status label should say 'Almost there...'")

	panel.slider.value = panel.target_frequency + 0.7
	panel._process(0.016)
	assert("Getting closer" in panel.status_label.text, "status label should say 'Getting closer'")

	panel.slider.value = panel.target_frequency + 1.2
	panel._process(0.016)
	assert("Tuning" in panel.status_label.text, "status label should say 'Tuning...'")

	print("✅ test_locking_logic passed")

func test_ui_updates():
	panel.slider.value = panel.target_frequency + 0.5
	panel._process(0.016)
	var expected = "Your Frequency: %.1f Hz" % panel.slider.value
	assert(panel.player_label.text == expected, "player_label not updating correctly")
	print("✅ test_ui_updates passed")

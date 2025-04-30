extends Control

# Node references (we’ll assign these in _ready for debug)
var target_label: Label
var player_label: Label
var slider: HSlider
var status_label: Label
var target_wave: ColorRect
var player_wave: ColorRect

# Game data
var target_frequency = 0.0
var tolerance = 0.1
var is_locked = false

func _ready():
	# 1) Assign nodes explicitly and check for errors
	target_label    = get_node("TargetFrequencyLabel")    as Label
	player_label    = get_node("PlayerFrequencyLabel")    as Label
	slider          = get_node("FrequencySlider")         as HSlider
	status_label    = get_node("StatusLabel")             as Label
	target_wave     = get_node("TargetEKGPanel")          as ColorRect
	player_wave     = get_node("PlayerEKGPanel")          as ColorRect

	# 2) Debug prints to confirm everything is found
	print("Children of FrequencyTuningPanel:", get_children())
	print("target_label:", target_label)
	print("player_label:", player_label)
	print("slider:", slider)
	print("status_label:", status_label)
	print("target_wave:", target_wave)
	print("player_wave:", player_wave)

	# 3) Initialize target frequency and slider
	target_frequency = randf_range(2.0, 5.0)
	# start slider at least 0.5 Hz away, randomly above or below
	var sign = 1 if randi() % 2 == 0 else -1
	var offset = randf_range(0.5, 1.5) * sign
	slider.value = clamp(target_frequency + offset, slider.min_value, slider.max_value)

	# 4) Update UI labels
	if target_label:
		target_label.text = "Target Frequency: %.1f Hz" % target_frequency
	if player_label:
		player_label.text = "Your Frequency: %.1f Hz" % slider.value

	# 5) Apply target freq to shader
	if target_wave and target_wave.material is ShaderMaterial:
		var mat = target_wave.material as ShaderMaterial
		mat.set_shader_parameter("freq", target_frequency)


func _process(delta):
	var t = Time.get_ticks_msec() / 1000.0
	var player_freq = slider.value

	# 1) Update shader params for animation
	if target_wave.material is ShaderMaterial:
		var target_mat = target_wave.material as ShaderMaterial
		target_mat.set_shader_parameter("time", t)

	if player_wave.material is ShaderMaterial:
		var player_mat = player_wave.material as ShaderMaterial
		player_mat.set_shader_parameter("time", t)
		player_mat.set_shader_parameter("freq", player_freq)

	# 2) Update UI labels
	if player_label:
		player_label.text = "Your Frequency: %.1f Hz" % player_freq

	# 3) Compute difference
	var diff = abs(player_freq - target_frequency)

	# 4) Update status and lock state
	if diff < tolerance:
		status_label.text = "✅ Frequency Locked!"
		is_locked = true
	else:
		is_locked = false
		if diff < 0.5:
			status_label.text = "Almost there..."
		elif diff < 1.0:
			status_label.text = "Getting closer"
		else:
			status_label.text = "Tuning..."

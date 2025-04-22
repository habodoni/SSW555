extends Control

@onready var target_label = $TargetFrequencyLabel
@onready var player_label = $PlayerFrequencyLabel
@onready var slider = $FrequencySlider
@onready var status_label = $StatusLabel
@onready var target_wave = $TargetEKGPanel
@onready var player_wave = $PlayerEKGPanel

var target_frequency = 0.0
var tolerance = 0.2  # Allowable margin for matching

func _ready():
	# Set a random target frequency between 2.0 and 5.0 Hz
	target_frequency = randf_range(2.0, 5.0)
	target_label.text = "Target Frequency: %.1f Hz" % target_frequency

	# Assign initial target frequency to the shader
	if target_wave.material is ShaderMaterial:
		var target_mat = target_wave.material as ShaderMaterial
		target_mat.set_shader_param("freq", target_frequency)

func _process(delta):
	var t = Time.get_ticks_msec() / 1000.0
	var player_freq = slider.value

	# Update shader params for animation
	if target_wave.material is ShaderMaterial:
		var target_mat = target_wave.material as ShaderMaterial
		target_mat.set_shader_param("time", t)

	if player_wave.material is ShaderMaterial:
		var player_mat = player_wave.material as ShaderMaterial
		player_mat.set_shader_param("time", t)
		player_mat.set_shader_param("freq", player_freq)

	# Update UI labels
	player_label.text = "Your Frequency: %.1f Hz" % player_freq

	# Determine if frequency is close enough to lock
	if abs(player_freq - target_frequency) < tolerance:
		status_label.text = "✅ Frequency Locked!"
	else:
		status_label.text = "Tuning..."

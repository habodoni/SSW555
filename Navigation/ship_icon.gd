extends Node2D

@export var trajectory_length := 15.0  
@export var prediction_steps := 1000 
@export var thrust_power := 200.0
@export var turn_speed := 4.0
@export var line_color := Color.WHITE
@export var planet_radius := 50.0

@onready var thrust_input: LineEdit = $ThrustInput
@onready var angle_input: LineEdit = $AngleInput
@onready var apply_button: Button = $ApplyButton
@onready var chart_button: Button = $ChartButton
@onready var status_label: Label = $StatusLabel
@onready var line := Line2D.new()

var velocity := Vector2.ZERO
var angle := 0.0
var gravity_bodies := []
var x_offset = 0
var y_offset = 0

func _ready():
	add_child(line)
	line.position = Vector2.ZERO
	line.width = 2
	line.default_color = line_color
	line.z_index = 10

	# Connect the button signal
	apply_button.pressed.connect(apply_input_values)
	chart_button.pressed.connect(complete_minigame)

func _process(delta):
	if get_parent().visible: #minigame does not work when player isnt actively playing it
		handle_input(delta)
		draw_trajectory()

	var angle_deg = angle * 180.0 / PI
	status_label.text = "Chart your path to Ganymede:\n
	Use left and right to change the angle of your spaceship\n
	Use up and down to change the thrust of your ship\n	
	Enter exact thrust and angles at the bottom of the screen\n
	You need to get past the moon, mars, the asteroid belt, and Jupiter's 
	gravitational fields in order to orbit Ganymede\n
	Try to get there using the least amount of thrust\n\n"
	status_label.text += "Thrust: %.1f\nAngle: %.2f°" % [thrust_power, fposmod(angle_deg, 360.0)]

func handle_input(delta):
	if Input.is_action_pressed("left"):
		angle -= turn_speed * delta
	if Input.is_action_pressed("right"):
		angle += turn_speed * delta
	if Input.is_action_pressed("up"):
		thrust_power += 10
	if Input.is_action_pressed("down"):
		thrust_power -= 10
	if thrust_power < 0:
		thrust_power = 0

func complete_minigame():
	GameState.set_system_status("navigation", true)

func apply_input_values():
	# Read values from LineEdits and apply them to thrust and angle
	var thrust_text = thrust_input.text
	var angle_text = angle_input.text

	if thrust_text.is_valid_float():
		thrust_power = thrust_text.to_float()

	if angle_text.is_valid_float():
		angle = deg_to_rad(angle_text.to_float())  # Convert degrees to radians
	
	thrust_input.text = ""
	angle_input.text = ""

func offset(x, y):
	x_offset = x
	y_offset = y

func draw_trajectory():
	var points: Array[Vector2] = []
	var pos = global_position
	var vel = Vector2.RIGHT.rotated(angle) * thrust_power
	var dt = trajectory_length / float(prediction_steps)
	var completed_steps

	gravity_bodies = get_tree().get_nodes_in_group("gravity_bodies")

	var orbiting = false
	var orbit_center = Vector2.ZERO
	var orbit_radius = 0.0
	var orbit_angle = 0.0
	var orbit_start = Vector2.ZERO
	var orbit = null

	for i in range(prediction_steps):
		if orbiting:
			orbit_angle += 2 * PI / (prediction_steps - completed_steps)
			var offset = Vector2(orbit_radius, 0).rotated(orbit_angle)
			pos = orbit_center + offset
			points.append(pos)
			continue

		var acc = Vector2.ZERO
		for body in gravity_bodies:
			var r = body.global_position - pos
			var dist = r.length()

			if dist > 0.1:
				var grav_strength = body.mass / (dist * dist)
				acc += r.normalized() * grav_strength

			if dist <= (body.radius + planet_radius) * body.scale.x * 2 / 3:
				orbiting = true
				orbit = body
				if body.isTarget():
					chart_button.show()
				completed_steps = i
				orbit_center = body.global_position
				orbit_radius = dist
				orbit_start = pos
				orbit_angle = (orbit_start - orbit_center).angle()
				points.append(orbit_start)
				break

		if not orbiting:
			vel += acc * dt
			pos += vel * dt
			points.append(pos)
	if not orbiting || orbit == null || not orbit.isTarget():
			chart_button.hide()
	var offset = Vector2(x_offset, y_offset)
	for i in range(points.size()):
		points[i] += offset
	line.points = points

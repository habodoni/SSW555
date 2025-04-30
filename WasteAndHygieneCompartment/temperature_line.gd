extends ColorRect

var velocity := 0.0
var acceleration := 600.0
var max_speed := 400.0

const MIN_Y := -400.0
const MAX_Y := 400.0


func _ready() -> void:
	global_position.y = 400.0  # Initial position

func _process(delta: float) -> void:
	if get_parent().active:
		if Input.is_action_pressed("up"):
			if global_position.y == 400:
				velocity = 0
			velocity -= acceleration * delta  # move up
		else:
			velocity += acceleration * delta  # move down

		# Clamp velocity to max speed
		velocity = clamp(velocity, -max_speed, max_speed)

		# Update and clamp position
		var new_y = global_position.y + velocity * delta
		new_y = clamp(new_y, MIN_Y, MAX_Y)

		global_position.y = new_y

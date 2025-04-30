extends Node2D

var velocity           : Vector2 = Vector2.ZERO
var random_accel_timer : float   = 0.0
var movement_bounds    : Rect2                          # injected from spawner

var max_speed := 1000.0

var color_y = "#b2b02dee"
var color_b = "#603f0eee"
var color_bl = "#247ec5ee"

func _ready() -> void:
	# Put this node into the “waste” group so the tube recognizes it
	add_to_group("waste")

	# Give it an initial gentle drift
	randomize()
	var angle  := randf() * TAU
	var speed  := randf_range(10.0, 30.0)
	velocity   = Vector2(cos(angle), sin(angle)) * speed

func _physics_process(delta: float) -> void:
	# Zero-g drift
	
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	
	position += velocity * delta

	# Bounce off containment box
	if not movement_bounds.has_point(position):
		if position.x < movement_bounds.position.x:
			position.x = movement_bounds.position.x
			velocity.x =  abs(velocity.x)
		elif position.x > movement_bounds.position.x + movement_bounds.size.x:
			position.x = movement_bounds.position.x + movement_bounds.size.x
			velocity.x = -abs(velocity.x)

		if position.y < movement_bounds.position.y:
			position.y = movement_bounds.position.y
			velocity.y =  abs(velocity.y)
		elif position.y > movement_bounds.position.y + movement_bounds.size.y:
			position.y = movement_bounds.position.y + movement_bounds.size.y
			velocity.y = -abs(velocity.y)

	# Small random nudges
	random_accel_timer -= delta
	if random_accel_timer <= 0.0:
		velocity += Vector2(randf_range(-5, 5), randf_range(-5, 5))
		random_accel_timer = randf_range(0.5, 1.5)
	


# Called by the tube when inside the suction cone
func apply_suction(suction_point: Vector2) -> void:
	var dir := (suction_point - position).normalized()
	velocity = dir * 200.0        # tweak 200.0 for stronger / weaker pull
	
func apply_rotation(suction_point: Vector2) -> void:
	var dir := (suction_point - position).normalized()
	velocity += dir * 50        # tweak 200.0 for stronger / weaker pull


func set_yellow():
	$ColorRect.color = Color(color_y)

func set_brown():
	$ColorRect.color = Color(color_b)
	

func set_blue():
	$ColorRect.color = Color(color_bl)

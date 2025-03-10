extends CharacterBody2D
@export var speed = 400

# Movement Code
func _physics_process(delta):
	get_input()
	move_and_slide()
	drain_health(delta)  # Call health drain every frame

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	#walking animation
	if input_direction == Vector2(0,0):
		$AnimatedSprite2D.play("default")
	elif input_direction.y == -1:
		$AnimatedSprite2D.play("UpWalk")
	elif input_direction.y == 1:
		$AnimatedSprite2D.play("DownWalk")
	elif input_direction.x == -1:
		$AnimatedSprite2D.play("LeftWalk")
	elif input_direction.x == 1:
		$AnimatedSprite2D.play("RightWalk")


# ==============================
# Health System
# ==============================

const MAX_HEALTH = 100
var health = MAX_HEALTH
var drain_time = 60.0  # Time in seconds for health to reach zero

@onready var health_bar = $HealthBar  # Ensure HealthBar is a child of Astronaut

func _ready():
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health

func drain_health(delta):
	var health_decrease_rate = MAX_HEALTH / drain_time
	health -= health_decrease_rate * delta
	health = max(health, 0)  # Prevent negative health
	health_bar.value = health

# Function to increase health when picking up an apple
func increase_health(amount: int):
	health += amount
	health = min(health, MAX_HEALTH)  # Ensure health does not exceed max
	health_bar.value = health
	print("Current Health: ", health)

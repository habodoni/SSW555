extends CharacterBody2D

@export var speed := 250
@export var navigation_skill := 1.0
@export var repair_skill := 1.0

var active_player = false

# Store base stats for reset after switching
var base_navigation_skill := 1.0
var base_repair_skill := 1.0
var base_speed := 250

var active_shape: RectangleShape2D
var not_active_shape: CircleShape2D

# Movement Code
func _physics_process(delta):
	if not get_parent().minigame_active:
		show()
		if(active_player):
			get_input()
			move_and_slide()
		drain_health(delta)  # Call health drain every frame
	else:
		hide()

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

func setup(active: bool, x: int, y: int):
	set_active_player(active)
	position = Vector2(x, y)
	

func set_active_player(active: bool):
	active_player = active
	if(active_player):
		$CollisionShape2D.disabled = false
		$Area2D/CollisionShape2D.disabled = true
	else:
		$CollisionShape2D.disabled = true
		$Area2D/CollisionShape2D.disabled = false
		$AnimatedSprite2D.play("default")
	

func _ready():
	base_navigation_skill = navigation_skill
	base_repair_skill = repair_skill
	base_speed = speed
	
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health
	add_to_group("player")
	create_collision_shapes()

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


func create_collision_shapes():
	active_shape = RectangleShape2D.new()
	active_shape.size = Vector2(64,32)
	not_active_shape = CircleShape2D.new()
	not_active_shape.radius = 65

func is_player():
	return active_player

extends CharacterBody2D

@export var speed := 250
@export var navigation_skill := 1.0
@export var repair_skill := 1.0

var active_player = false
var role = "Astronaut"

# Store base stats for reset after switching
@onready var switch_sound = $SwitchSound
var base_navigation_skill := 1.0
var base_repair_skill := 1.0
var base_speed := 250

var active_shape: RectangleShape2D
var not_active_shape: CircleShape2D

# Movement Code
func _physics_process(delta):
	if not get_parent().minigame_active:
		show()
		if active_player:
			get_input()
			move_and_slide()
		drain_health(delta)
	else:
		hide()

		# ✅ Force stop walking sound when minigame is active
		if $WalkSound.playing:
			$WalkSound.stop()


func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
	# Check if player is moving with a small threshold to account for floating point imprecision
	var is_moving = input_direction.length() > 0.3
	
	# Play walking animation and sound only when moving
	if is_moving:
		if input_direction.y < -0.1:
			$AnimatedSprite2D.play("UpWalk")
		elif input_direction.y > 0.1:
			$AnimatedSprite2D.play("DownWalk")
		elif input_direction.x < -0.1:
			$AnimatedSprite2D.play("LeftWalk")
		elif input_direction.x > 0.1:
			$AnimatedSprite2D.play("RightWalk")
			
		# Start walking sound if not already playing
		if not $WalkSound.playing:
			$WalkSound.play()
	else:
		# Player has stopped moving
		$AnimatedSprite2D.play("default")
		
		# IMPORTANT: Always force stop the sound when not moving
		$WalkSound.stop()




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
	

var has_initialized = false  # ← Flag to track first-time setup

func set_active_player(active: bool):
	active_player = active
	if active_player:
		$CollisionShape2D.disabled = false
		$Area2D/CollisionShape2D.disabled = true

		# ✅ Don't play the sound during initial setup
		if has_initialized and switch_sound:
			switch_sound.stop()  # Ensure no delay from overlapping sound
			switch_sound.play()
	else:
		$CollisionShape2D.disabled = true
		$Area2D/CollisionShape2D.disabled = false
		$AnimatedSprite2D.play("default")
	has_initialized = true  # Mark setup complete after first run


	

func _ready():
	base_navigation_skill = navigation_skill
	base_repair_skill = repair_skill
	base_speed = speed
	
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health
	add_to_group("player")
	create_collision_shapes()

func drain_health(delta):
	if not active_player:
		return               # 🚫 don’t drain inactive astronauts

	var rate = MAX_HEALTH / drain_time
	health -= rate * delta
	health = max(health, 0)
	health_bar.value = health

	if health <= 0:
		_on_health_depleted()

func _on_health_depleted():
	# show “Game Over – Health Reached Zero” and restart entire game
	get_tree().change_scene_to_file("res://GameOver/game_over.tscn")


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

func set_role(role_input):
	role = role_input
	$LabelNode/Label.text = role

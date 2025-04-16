extends Node2D

@export var mass: float = 100000.0  # Planet's mass
@onready var animated_sprite := $AnimatedSprite2D
var radius: float = 50.0  # Set a default radius for the planet (change as needed)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("gravity_bodies")  # Add planet to gravity bodies group
	

	# Start playing the animation (if it's not playing already)
	animated_sprite.play("Asteroid3")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# You can now use the 'radius' variable for any necessary calculations
	pass

func isTarget():
	return false

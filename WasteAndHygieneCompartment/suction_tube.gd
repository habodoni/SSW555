extends Node2D

@export var move_speed  : float = 200.0   # arrow-key speed

# One rectangle: x = −300 … +300, y = −200 … +600  (original 400 px tall + 400 px extra)
const MOVE_BOUNDS : Rect2 = Rect2(Vector2(-300, -200), Vector2(600, 600))

@onready var suction_area    : Area2D = $SuctionArea
@onready var collection_area : Area2D = $CollectionArea
var particles_obtained = 0

var active = false

func _ready() -> void:
	suction_area.monitoring    = true
	collection_area.monitoring = true


func _physics_process(delta: float) -> void:
	if(active):
		handle_movement(delta)
		handle_suction()


func activate():
	active = true
	particles_obtained = 0

func deactivate():
	active = false

# ─────────────────────────────────────────────────────────────
#  Movement (up / down / left / right)
# ─────────────────────────────────────────────────────────────
func handle_movement(delta: float) -> void:
	var input_vec := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down")  - Input.get_action_strength("up")
	).normalized()

	position += input_vec * move_speed * delta

	# clamp into the enlarged bounds
	position.x = clamp(position.x,
		MOVE_BOUNDS.position.x,
		MOVE_BOUNDS.position.x + MOVE_BOUNDS.size.x)

	position.y = clamp(position.y,
		MOVE_BOUNDS.position.y,
		MOVE_BOUNDS.position.y + MOVE_BOUNDS.size.y)


# ─────────────────────────────────────────────────────────────
#  Suction & collection
# ─────────────────────────────────────────────────────────────
func handle_suction() -> void:
	# Pull particles that are in the cone
	for area in suction_area.get_overlapping_areas():
		var particle : Node = area.get_parent()
		if particle.is_in_group("waste"):
			particle.apply_suction(global_position)

	# Delete particles that reach the mouth
	for area in collection_area.get_overlapping_areas():
		var particle : Node = area.get_parent()
		if particle.is_in_group("waste"):
			particle.queue_free()
			particles_obtained += 1
			if particles_obtained == 30:
				get_parent().next()

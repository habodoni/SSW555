extends Node2D

@onready var suction_area    : Area2D = $SuctionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent().active:
		handle_suction()

func handle_suction() -> void:
	# Pull particles that are in the cone
	for area in suction_area.get_overlapping_areas():
		var particle : Node = area.get_parent()
		if particle.is_in_group("waste"):
			particle.apply_rotation(global_position)

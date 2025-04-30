class_name SpaceFood
extends Area2D

@export var heal_amount: int = 20
signal food_eaten

# Update this to reference the node directly
@onready var eat_sound = $EatSound

func _ready():
	add_to_group("space_food")

	# If we're not in active gameplay, delete this food
	if not is_in_gameplay():
		print("🧽 SpaceFood auto-cleaned (not in gameplay scene)")
		queue_free()
		return

	connect("body_entered", _on_body_entered)
	
func is_in_gameplay() -> bool:
	return get_tree().current_scene.name == "SpaceTravel"


func _on_body_entered(body: Node2D) -> void:
	print("body entered: ", body.name)
	if body.has_method("increase_health"):
		print("Food touched by: ", body.name)
		body.increase_health(heal_amount)
		
		# Play the eating sound
		if eat_sound and eat_sound.stream:
			eat_sound.play()
			await get_tree().create_timer(0.2).timeout  # short delay before deleting
		queue_free()

		emit_signal("food_eaten")
		queue_free()
	

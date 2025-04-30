class_name SpaceFood
extends Area2D

@export var heal_amount: int = 20
signal food_eaten

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	print("body entered: ", body.name)

	if body.has_method("increase_health"):
		print("Food touched by: ", body.name)
		body.increase_health(heal_amount)
		emit_signal("food_eaten")
		queue_free()

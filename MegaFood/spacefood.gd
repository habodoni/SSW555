extends Area2D  # Ensure Apple is an Area2D, NOT Node2D

@export var heal_amount: int = 20  # Amount of health the apple restores

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	#print("body entered")
	if body is CharacterBody2D:  # Ensure only the player picks it up
		if body.has_method("increase_health"):
			body.increase_health(heal_amount)  # Increase player's health
		print("+%d Health!" % heal_amount)
		queue_free()  # Remove the apple after being picked up

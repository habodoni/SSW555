extends Area2D

@onready var light = $PointLight2D
@onready var highlight = load("res://TaskMarker/Highlight.tres")

#represents if a player is in switch range
var player_near = false
#represents the player in switch range
var player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	light.hide()
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_near and Input.is_action_just_pressed("Switch"):
		print("x")
		if player != null:
			switch_player()

func switch_player():
	if not player or player == get_parent():
		return

	# Reset stats on old astronaut
	player.set_active_player(false)
	player.navigation_skill = player.base_navigation_skill
	player.repair_skill = player.base_repair_skill
	player.speed = player.base_speed

	# Activate new astronaut (parent of this Area2D)
	var new_astronaut = get_parent()
	new_astronaut.set_active_player(true)

	# Apply stat boosts
	new_astronaut.navigation_skill += 0.2
	new_astronaut.repair_skill += 0.2
	new_astronaut.speed += 20

	print("Switched to:", new_astronaut.name)
	print("→ Boosted Nav:", new_astronaut.navigation_skill,
		  "Repair:", new_astronaut.repair_skill,
		  "Speed:", new_astronaut.speed)

	light.hide()
	player_near = false
	player = null


func _on_body_entered(body: Node2D) -> void:
	print("body entered")
	if body is CharacterBody2D:
		if body.has_method("is_player"):
			if body.is_player():
				light.show()
				player_near = true
				player = body

func _on_body_exited(body: Node2D) -> void:
	print("body exited")
	if body is CharacterBody2D:
		if body.has_method("is_player"):
			if body.is_player():
				light.hide()
				player_near = false
				player = false

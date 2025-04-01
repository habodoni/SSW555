extends Area2D

@onready var light = $PointLight2D
@onready var highlight = load("res://TaskMarker/Highlight.tres")

var player_near = false
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
	player.set_active_player(false)
	var this_astronaut = get_parent()
	this_astronaut.set_active_player(true)

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

extends Area2D

@export var interact_key: String = "e"

var player_near = null
var active = true

@onready var light = $PointLight2D
@onready var base_gradient = load("res://TaskMarker/BaseGradient.tres")
@onready var highlight = load("res://TaskMarker/Highlight.tres")
@onready var rect = $ColorRect
var minigame

var role = null

func _ready():
	rect.visible = false
	light.texture = light.texture.duplicate()
	light.texture.gradient = light.texture.gradient.duplicate()
	light.texture.gradient = base_gradient
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	$Label.hide()

func _process(delta):
	if active && minigame != null:
		if player_near != null and Input.is_action_just_pressed("interact"):
			if (role == null || player_near.role == role):
				$Label.hide()
				if get_parent().minigame_active:
					end_task()
				else:
					begin_task()
			else:
				$Label.text = "Wrong Astronaut switch to:\n" + role
				$Label.show()

func activate():
	active = true
	show()

func deactivate():
	active = false
	hide()

func setup(game):
	minigame = game
	minigame.hide()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body.has_method("is_player"):
			if body.is_player():
				light.texture.gradient = highlight
				player_near = body

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body.has_method("is_player"):
			if body.is_player():
				light.texture.gradient = base_gradient
				player_near = null

func begin_task():
	minigame.visible = true
	rect.visible = true
	light.visible = false
	get_parent().set_minigame_active(true)

func end_task():
	minigame.visible = false
	rect.visible = false
	light.visible = true
	get_parent().set_minigame_active(false)

func set_role(role_input):
	role = role_input

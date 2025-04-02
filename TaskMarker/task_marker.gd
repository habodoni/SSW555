extends Area2D

@export var interact_key: String = "e"

var player_near = false
var active = true

@onready var light = $PointLight2D
@onready var base_gradient = load("res://TaskMarker/BaseGradient.tres")
@onready var highlight = load("res://TaskMarker/Highlight.tres")
@onready var rect = $ColorRect
var minigame

func _ready():
	rect.visible = false
	light.texture = light.texture.duplicate()
	light.texture.gradient = light.texture.gradient.duplicate()
	light.texture.gradient = base_gradient
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _process(delta):
	if active:
		if player_near and Input.is_action_just_pressed("interact"):
			if get_parent().minigame_active:
				end_task()
			else:
				begin_task()

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
				player_near = true

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body.has_method("is_player"):
			if body.is_player():
				light.texture.gradient = base_gradient
				player_near = false

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

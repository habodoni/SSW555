extends Area2D

@export var interact_key: String = "e"

var player_near = false
var task_active = false

@onready var light = $PointLight2D
@onready var base_gradient = load("res://TaskMarker/BaseGradient.tres")
@onready var highlight = load("res://TaskMarker/Highlight.tres")
@onready var minigame = $OxygenMinigame
@onready var rect = $ColorRect

func _ready():
	minigame.visible = false
	rect.visible = false
	light.texture.gradient = base_gradient
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _process(delta):
	if player_near and Input.is_action_just_pressed("interact"):
		if task_active:
			end_task()
		else:
			begin_task()

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
	task_active = true
	rect.visible = true
	light.visible = false

func end_task():
	minigame.visible = false
	task_active = false
	rect.visible = false
	light.visible = true

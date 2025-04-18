extends Node2D

@onready var ship_icon = $ShipIcon
var Task_Manager = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func offset(x_offset, y_offset):
	ship_icon.set_draw_offset(x_offset, y_offset)

func set_task_manager(task_manager):
	Task_Manager = task_manager

func task_done():
	if Task_Manager != null:
		Task_Manager.task_done()

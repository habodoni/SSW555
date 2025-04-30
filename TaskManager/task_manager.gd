extends Node2D

var tasks = ["Navigate to Ganymede", "Replace Oxygen Tank", "Manage Human Waste"]
var task_markers = []
var tasks_done = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = "Task:"  # Ensure it's cleared
	$Label.visible = true  # Just in case

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var label_node = $Label
	var display_text = ""
	if tasks_done < tasks.size():
		display_text = "Task: " + tasks[tasks_done]
	else:
		display_text = "All Tasks Complete: Send to mission control"
	label_node.text = display_text

func set_task_markers(markers: Array):
	task_markers = markers
	for task_marker in task_markers:
		task_marker.deactivate()
	task_markers[0].activate()

func task_done():
	task_markers[tasks_done].deactivate()
	task_markers[tasks_done].end_task()
	tasks_done = tasks_done + 1
	if tasks_done < tasks.size():
		task_markers[tasks_done].activate()

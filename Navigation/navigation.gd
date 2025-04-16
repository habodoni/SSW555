extends Node2D

@onready var ship_icon = $ShipIcon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func offset(x_offset, y_offset):
	ship_icon.offset(x_offset, y_offset)

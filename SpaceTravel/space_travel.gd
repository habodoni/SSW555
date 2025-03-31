extends Node2D

var astronaut = preload("res://Astronaut/Astronaut.tscn")  # Preloads at compile-time



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var astronaut_1 = astronaut.instantiate()
	astronaut_1.setup(true, 0, 0)
	add_child(astronaut_1)
	var astronaut_2 = astronaut.instantiate()
	astronaut_2.setup(false, 416, -180)
	add_child(astronaut_2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

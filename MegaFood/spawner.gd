extends Node2D

@export var space_food_scene: PackedScene
@export var number_of_space_foods: int = 5
@export var spawn_points_node_path: NodePath
@export var respawn_delay: float = 10.0

var spawn_points = []

func _ready():
	randomize()
	spawn_points = get_node(spawn_points_node_path).get_children()
	spawn_space_foods()

func spawn_space_foods():
	var points_copy = spawn_points.duplicate()
	points_copy.shuffle()

	for i in range(min(number_of_space_foods, points_copy.size())):
		var food_instance = space_food_scene.instantiate() as SpaceFood
		food_instance.position = points_copy[i].global_position
		food_instance.connect("food_eaten", Callable(self, "_on_food_eaten"))
		add_child(food_instance)

		print("Spawned food at: ", food_instance.position)

func _on_food_eaten():
	print("Food was eaten! Respawning in a few seconds...") # This is not working yet for some reason - need to debug respawning
	await get_tree().create_timer(respawn_delay).timeout

	var marker = spawn_points[randi() % spawn_points.size()]
	var food_instance = space_food_scene.instantiate() as SpaceFood
	food_instance.position = marker.global_position
	food_instance.connect("food_eaten", Callable(self, "_on_food_eaten"))
	add_child(food_instance)

	print("Respawned food at: ", food_instance.position)

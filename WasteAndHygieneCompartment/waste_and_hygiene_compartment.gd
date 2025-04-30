extends Node2D

@onready var particles_container = $ParticlesContainer  # Node2D to hold all particles
@onready var suction_tube = $SuctionTube
@onready var instructions = $Label
@onready var next_button = $NextButton
@onready var screen_dim = $ColorRect2
@onready var UPA = $UrineProcessorAssembly

var level = 0

var prompt_1 = "In space when you use the bathroom, suction is used to collect waste since it will float away in zero gravity.\n Try sucking up the urine with the suction tube by using Up, Down, Left, Right."

var prompt_2 = "In space, solid waste goes to a separate sanitation station.\n Now use the suction tube just like before: press Up, Down, Left, and Right to capture the feces"

var prompt_3 = "The feces will be stored and later disposed of.\n The urine however needs to be recycled into drinkable water. \n To do this you need to first put the urine into a centrifuge.\n Then it needs to be heated up to separate the water from the rest of the urine\n\n Gently tap UP to increase the temperature in the centrifuge. \n Try to keep it in the green for 5 seconds"

var prompt_4 = "Good job, you seperated the water from the urine.\nThe water will now be filtered to remove microbes and chemicals.\n Then it will be drinkable for all the astronauts.\n\n Press E to go back to the spaceship."

var label_1 = "Liquid Waste Station"
var label_2 = "Solid Waste Station"
var label_3 = "Urine Processing Assembly"

var WasteParticle = preload("res://WasteAndHygieneCompartment/WasteParticle.tscn") 
var bounds = Rect2(Vector2(-300, -200), Vector2(600, 400))  # (top-left, size)


func _ready():
	spawn_particles_yellow(30)  # for example, spawn 30 particles
	next_button.pressed.connect(_on_next_pressed)
	instructions.text = prompt_1
	UPA.hide()
	$StationLabel.text = label_1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_particles_yellow(count: int):
	for i in range(count):
		var particle = WasteParticle.instantiate()
		particle.movement_bounds = bounds
		particle.set_yellow()
		add_child(particle)
		

func spawn_particles_brown(count: int):
	for i in range(count):
		var particle = WasteParticle.instantiate()
		particle.movement_bounds = bounds
		particle.set_brown()
		add_child(particle)

func _on_next_pressed():
	if level == 0:
		suction_tube.activate()
		screen_dim.hide()
		next_button.hide()
	elif level == 1:
		suction_tube.activate()
		screen_dim.hide()
		next_button.hide()
	elif level == 2:
		screen_dim.hide()
		next_button.hide()

func next():
	level += 1
	if level == 1:
		instructions.text = prompt_2
		suction_tube.deactivate()
		screen_dim.show()
		next_button.show()
		suction_tube.position = Vector2(0, 400)
		spawn_particles_brown(30)
		$StationLabel.text = label_2
	elif level == 2:
		instructions.text = prompt_3
		suction_tube.deactivate()
		suction_tube.hide()
		screen_dim.show()
		next_button.show()
		$ColorRect.hide()
		UPA.show()
		UPA.activate()
		$StationLabel.text = label_3
	else:
		UPA.hide()
		UPA.deactivate()
		screen_dim.show()
		instructions.text = prompt_4
		$StationLabel.hide()

extends Node2D

var astronaut = preload("res://Astronaut/Astronaut.tscn")  # Preloads at compile-time

@onready var oxygen_minigame = $ElektronMinigame
@onready var oxygen_minigame_marker = $OxygenTaskMarker
@onready var warning_label = $OxygenWarning


@onready var minigame_2 = $Task2
@onready var minigame_2_marker = $TaskMarker2

@onready var minigame_3 = $Navigation
@onready var minigame_3_marker = $TaskMarker3

@onready var system_diagnostics = $SystemDiagnostics
@onready var system_diagnostics_marker = $SystemDiagnosticsMarker

@onready var inventory = $ResourceTracker
@onready var inventory_marker = $InventoryMarker

@onready var task_manager = $TaskManager

var task_deck = []

var minigame_active = false

var count = 0
var cardDeal = 250


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var astronaut_1 = astronaut.instantiate()
	add_child(astronaut_1)
	astronaut_1.setup(true, 0, 0)
	var astronaut_2 = astronaut.instantiate()
	add_child(astronaut_2)
	astronaut_2.setup(false, 416, -180)
	var task_markers = [minigame_3_marker, oxygen_minigame_marker]
	minigame_2_marker.deactivate()
	stack_deck()
	task_manager.set_task_markers(task_markers)

func stack_deck():
	oxygen_minigame_marker.setup(oxygen_minigame)
	minigame_2_marker.setup(minigame_2)
	minigame_3_marker.setup(minigame_3)
	system_diagnostics_marker.setup(system_diagnostics)
	inventory_marker.setup(inventory)
	
	minigame_3.offset(770, -320)
	
	oxygen_minigame.set_task_manager(task_manager)
	minigame_3.set_task_manager(task_manager)
	
	system_diagnostics_marker.activate()
	inventory_marker.activate()
	oxygen_minigame_marker.deactivate()
	minigame_2_marker.deactivate()
	minigame_3_marker.deactivate()
	task_deck = [minigame_3_marker, oxygen_minigame_marker, minigame_2_marker]
	#task_deck.shuffle()

func deal_deck():
	task_deck.pop_at(0).activate()

func set_minigame_active(active: bool):
	minigame_active = active
	if active:
		oxygen_minigame_marker.light.hide()
		minigame_2_marker.light.hide()
		minigame_3_marker.light.hide()
		system_diagnostics_marker.light.hide()
		inventory_marker.light.hide()
		task_manager.hide()
	else:
		oxygen_minigame_marker.light.show()
		minigame_2_marker.light.show()
		minigame_3_marker.light.show()
		system_diagnostics_marker.light.show()
		inventory_marker.light.show()
		task_manager.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if not minigame_active:
		#if (count == cardDeal && task_deck.size() != 0):
			#deal_deck()
			#count = 0
		#else:
			#count += 1
			
	# Oxygen warning check
	if oxygen_minigame.is_oxygen_critical:
		warning_label.visible = true
		warning_label.text = "CRITICAL OXYGEN: %.1f%%" % oxygen_minigame.oxygen_level
	else:
		warning_label.visible = false

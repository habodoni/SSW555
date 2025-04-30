# UPA_Game.gd  — attach to the root Node2D of the scene
extends Node2D

@onready var WasteParticle = preload("res://WasteAndHygieneCompartment/WasteParticle.tscn")
var active = false

# ─────────────────────────────────────────────────────────────
#  Bounding rectangles
# ─────────────────────────────────────────────────────────────
var bounds       := Rect2(Vector2(-200, -200), Vector2(400, 400))   # large box
var small_bounds := Rect2(Vector2(-50,  -50),  Vector2(100, 100))   # small box

# ─────────────────────────────────────────────────────────────
#  Particle groups
# ─────────────────────────────────────────────────────────────
var brine : Array = []    # 10 % of particles
var water : Array = []    # 90 % of particles

# ─────────────────────────────────────────────────────────────
#  Smooth-transition data
# ─────────────────────────────────────────────────────────────
const TRANSITION_TIME := 1.0            # seconds to finish the blend
var   blend_t          := 1.0           # 0 → 1 progress (1 = idle)
var   start_rects  : Dictionary = {}    # particle → Rect2 at blend start
var   target_rects : Dictionary = {}    # particle → Rect2 goal

var time_heating = 0
var heating = false

# ─────────────────────────────────────────────────────────────
#  Life-cycle
# ─────────────────────────────────────────────────────────────
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if(active):
		_update_blending(delta)
		var line_height = $TemperatureLine.global_position.y
		if(line_height > 30):
			cool()
		elif(line_height < -30):
			overheat()
		else: 
			heat()
		if(heating):
			time_heating += delta
			if time_heating > 5:
				get_parent().next()
		else:
			time_heating = 0

# ─────────────────────────────────────────────────────────────
#  Particle spawning
# ─────────────────────────────────────────────────────────────
func spawn_particles(count: int) -> void:
	for i in range(count):
		var p: Node2D = WasteParticle.instantiate()
		if i < 5:           # first 10 % = brine
			brine.append(p)
		else:
			water.append(p)

		p.movement_bounds = small_bounds   # start everything in small box
		p.set_yellow()                     # visual default
		add_child(p)

# ─────────────────────────────────────────────────────────────
#  Smooth bounds-changing helper
# ─────────────────────────────────────────────────────────────
func _begin_transition(particles: Array, target: Rect2) -> void:
	for p in particles:
		start_rects[p]  = p.movement_bounds    # current rect
		target_rects[p] = target               # where we want to go
	blend_t = 0.0                              # restart lerp clock

func _update_blending(delta: float) -> void:
	if blend_t >= 1.0:
		return                                # nothing to do

	blend_t = clamp(blend_t + delta / TRANSITION_TIME, 0.0, 1.0)

	for p in start_rects.keys():
		var from: Rect2 = start_rects[p]
		var to  : Rect2 = target_rects[p]
		var pos  := from.position.lerp(to.position, blend_t)
		var size := from.size    .lerp(to.size,     blend_t)
		p.movement_bounds = Rect2(pos, size)

	if blend_t >= 1.0:
		start_rects.clear()
		target_rects.clear()

# ─────────────────────────────────────────────────────────────
#  Button callbacks
# ─────────────────────────────────────────────────────────────
func heat() -> void:
	_begin_transition(brine, small_bounds)   # brine stays tight
	_begin_transition(water, bounds)         # water expands
	for p in brine: p.set_yellow()
	for p in water: p.set_blue()
	heating = true

func cool() -> void:
	_begin_transition(brine, small_bounds)
	_begin_transition(water, small_bounds)
	for p in brine: p.set_yellow()
	for p in water: p.set_yellow()
	heating = false

func overheat() -> void:
	_begin_transition(brine, bounds)
	_begin_transition(water, bounds)
	for p in brine: p.set_yellow()
	for p in water: p.set_yellow()
	heating = false

func activate():
	spawn_particles(30)
	active = true

func deactivate():
	active = false

extends Node

var upa          # UrineProcessorAssembly
var compartment  # WasteAndHygieneCompartment
var particle     # WasteParticle

func _ready():
	print("🚀 Running Waste Management tests...")

	upa = load("res://WasteAndHygieneCompartment/UrineProcessorAssembly.tscn").instantiate()
	compartment = load("res://WasteAndHygieneCompartment/WasteAndHygieneCompartment.tscn").instantiate()
	particle = load("res://WasteAndHygieneCompartment/WasteParticle.tscn").instantiate()

	# Add as children so _ready() runs
	add_child(upa)
	add_child(compartment)
	add_child(particle)

	await get_tree().process_frame  # Let their _ready() finish

	run_all_tests()

func run_all_tests():
	test_upa()
	test_compartment()
	test_particle()
	print("✅ All tests completed!")

# ───────────── UrineProcessorAssembly tests ─────────────
func test_upa():
	upa.spawn_particles(10)
	assert(upa.brine.size() + upa.water.size() == 10, "UPA spawn_particles failed")

	upa.heat()
	assert(upa.heating == true, "UPA did not heat")

	upa.cool()
	assert(upa.heating == false, "UPA did not cool")

	print("✅ UrineProcessorAssembly.tscn passed")

# ───────────── WasteAndHygieneCompartment tests ─────────────
func test_compartment():
	var old_level = compartment.level
	compartment.next()
	assert(compartment.level == old_level + 1, "Compartment next() did not increase level")

	print("✅ WasteAndHygieneCompartment.tscn next() passed")

# ───────────── WasteParticle tests ─────────────
func test_particle():
	particle.position = Vector2(100, 100)
	particle.apply_suction(Vector2(0, 0))
	assert(particle.velocity.length() > 0, "Particle apply_suction failed")
	
	particle.set_yellow()
	assert(particle.has_node("ColorRect"), "Particle missing ColorRect")
	print("✅ WasteParticle.tscn suction + color passed")

extends Area2D

signal unit_placed

func _ready():
	# Make sure monitoring is enabled for collision detection
	monitoring = true
	monitorable = true
	
	# Debug output
	print("LiquidUnitSlot is ready at position: ", global_position)

# This gets called when another body enters this area
func _on_body_entered(body):
	print("Body entered: ", body.name)
	
# This gets called when another area enters this area
func _on_area_entered(area):
	print("Area entered: ", area.name)
	if area.name == "NewLiquidUnit":
		print("Liquid unit has been placed in slot!")
		emit_signal("unit_placed", area)

extends Area2D

var is_dragging = false

func _ready():
	# Make sure input processing is enabled
	input_pickable = true

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _is_mouse_over():
			is_dragging = true
		elif !event.pressed:
			is_dragging = false

	if event is InputEventMouseMotion and is_dragging:
		global_position += event.relative

func _is_mouse_over() -> bool:
	# Simple rectangle bounds checking
	var mouse_pos = get_global_mouse_position()
	
	# Get the collision shape
	var coll_shape = $CollisionShape2D
	if not coll_shape or not coll_shape.shape:
		return false
		
	# Get transform and shape data
	var shape = coll_shape.shape
	var shape_transform = coll_shape.global_transform
	
	if shape is RectangleShape2D:
		# Convert mouse position to local coordinates
		var local_mouse_pos = shape_transform.affine_inverse() * mouse_pos
		
		# Check if point is inside rectangle
		var half_extents = shape.size / 2
		return (local_mouse_pos.x >= -half_extents.x and 
				local_mouse_pos.x <= half_extents.x and 
				local_mouse_pos.y >= -half_extents.y and 
				local_mouse_pos.y <= half_extents.y)
	
	# Fallback to simplified check using overlapping bodies
	return overlaps_point(mouse_pos)

# Custom function to check if a point overlaps with this area
func overlaps_point(point: Vector2) -> bool:
	# Simple distance check (only works for circular/spherical shapes)
	var shape = $CollisionShape2D.shape
	if shape is CircleShape2D:
		var distance = point.distance_to($CollisionShape2D.global_position)
		return distance <= shape.radius
	
	# For non-circular shapes, we'll need to use a more basic approach
	# Create a temporary collision point at the mouse position for testing
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = point
	query.collision_mask = collision_mask
	
	var result = space_state.intersect_point(query)
	for collision in result:
		if collision.collider == self:
			return true
	
	return false

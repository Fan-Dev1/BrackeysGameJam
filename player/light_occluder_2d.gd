@tool
extends LightOccluder2D

@export var left_side := false
@export var outer_size := 1930.0
@export var radius := 1080.0
@export var sides := 64

@export_tool_button("update_circle_points") var acs := update_circle_points_outer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func update_circle_points() -> void:
	var points: PackedVector2Array = []
	for i in range(sides):
		var angle = TAU * i / sides  # TAU = 2*PI
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	self.occluder.polygon = points


func update_circle_points_outer():
	var points: PackedVector2Array = []
	if left_side:
		points.append(Vector2(-outer_size, -outer_size))
		points.append(Vector2(0.0, -outer_size))
	
	# Circle (clockwise to "cut out")
	var ran := range(sides, -1, -1)
	for i in ran:
		var angle = TAU * i / sides
		var pos := Vector2(cos(angle), sin(angle)) * radius
		if left_side and pos.x <= 0.0:
			points.append(pos)
		elif not left_side and pos.x >= 0.0:
			points.append(pos)
	
	if left_side:
		points.append(Vector2(0.0,  outer_size))
		points.append(Vector2(-outer_size,  outer_size))
	
	self.occluder.polygon = points

class_name GuardPosition
extends Resource

@export_range(0.0, 360.0, 0.1, "radians_as_degrees") var rotation := 0.0
@export var duration_min_sec := 3.0
@export var duration_max_sec := 3.0
@export var target_marker : Vector2 = Vector2.ZERO

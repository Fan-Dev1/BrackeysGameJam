class_name CameraVisionConfig
extends VisionConeConfig


@export var rotaton_speed := 1.0 : set = set_rotaton_speed

@export_range(-180.0, 180.0, 0.1, "radians_as_degrees") 
var left_limit := PI / -2.0 : set = set_left_limit

@export_range(-180.0, 180.0, 0.1, "radians_as_degrees") 
var right_limit := PI / 2.0 : set = set_right_limit


func set_rotaton_speed(_rotaton_speed: float) -> void:
	if not is_equal_approx(rotaton_speed, _rotaton_speed):
		rotaton_speed = _rotaton_speed
		emit_changed()


func set_left_limit(_left_limit: float) -> void:
	if not is_equal_approx(left_limit, _left_limit):
		left_limit = _left_limit
		emit_changed()


func set_right_limit(_right_limit: float) -> void:
	if not is_equal_approx(right_limit, _right_limit):
		right_limit = _right_limit
		emit_changed()

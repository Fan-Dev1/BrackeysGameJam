@tool
class_name SecurityCamera
extends Node2D

enum CameraState { NORMAL, TRACKING, OFF }

@export var controlling_lever : LeverButton
@export var radius := 256.0
@export var rotaton_speed: float
@export var assigned_guard : SecurityGuard
@export_range(0.0, 360.0, 0.1, "radians_as_degrees") 
var fov := PI / 4.0
@export_range(-180.0, 180.0, 0.1, "radians_as_degrees") 
var left_limit := PI / -2.0
@export_range(-180.0, 180.0, 0.1, "radians_as_degrees") 
var right_limit := PI / 2.0

@export var camera_position_index := 0
@export var camera_positions: Array[CameraPosition] = []

@onready var position_timer: Timer = $PositionTimer
@onready var tracking_reset_timer: Timer = $TrackingResetTimer
@onready var camera_area_2d: Area2D = $CameraArea2D
@onready var camera_fov: Polygon2D = %CameraFov
@onready var camera_collision: CollisionPolygon2D = %CameraCollision
@onready var status_color_rect: ColorRect = %StatusColorRect

var state := CameraState.NORMAL : set = set_state
var tracking_target: Node2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_update_fov_polygon()
	_ready_camera_rotation()
	if is_controlled_by_lever():
		controlling_lever.lever_flipped.connect(_on_lever_flipped)
	if !assigned_guard:
		assigned_guard = get_tree().get_first_node_in_group("Guard")

func _ready_camera_rotation() -> void:
	if not camera_positions.is_empty():
		camera_position_index = wrapi(camera_position_index, 0, camera_positions.size())
		var camera_position := camera_positions[camera_position_index]
		rotate_camera_toward(camera_position)


func _physics_process(delta: float) -> void:
	if OS.is_debug_build():
		queue_redraw()
	if Engine.is_editor_hint():
		_update_fov_polygon()
		
		camera_position_index = wrapi(camera_position_index, 0, camera_positions.size())
		var camera_position := camera_positions[camera_position_index]
		rotate_camera_toward(camera_position)
	else:
		match state:
			CameraState.NORMAL: _normal_process(delta)
			CameraState.TRACKING: _tracking_process(delta)
			CameraState.OFF: pass


func _normal_process(delta: float) -> void:
	var camera_position := camera_positions[camera_position_index]
	rotate_camera_toward(camera_position, delta)
	_scan_for_player()
	# if camera reached camera_position --> start position_timer
	var angle_diff := angle_difference(camera_area_2d.rotation, camera_position.rotation)
	if is_zero_approx(angle_diff) and position_timer.is_stopped():
		var duration := randf_range(camera_position.duration_min_sec, camera_position.duration_max_sec)
		position_timer.start(duration)


func _scan_for_player() -> void:
	for body: Node2D in camera_area_2d.get_overlapping_bodies():
		# alert about spotted player and track him
		if body is Player:
			if !body.player_is_hidden:
				tracking_target = body
				assigned_guard.player_detected_elsewhere(body.global_position)
				state = CameraState.TRACKING
		elif body is CookieProjectile:
			tracking_target = body
			state = CameraState.TRACKING


func _on_position_timer_timeout() -> void:
	# shift to next camera_position
	camera_position_index += 1
	camera_position_index = wrapi(camera_position_index, 0, camera_positions.size())


func _tracking_process(delta: float) -> void:
	queue_redraw()
	if not is_instance_valid(tracking_target):
		# target / distraction cookie seems to be invalid --> start tracking_reset_timer
		if tracking_reset_timer.is_stopped():
			tracking_reset_timer.start()
		tracking_target = null
		return
	
	if camera_area_2d.overlaps_body(tracking_target):
		# Maintain focus on the target, angle the camera toward it, and report the position
		var target_camera_position := to_camera_position(tracking_target)
		rotate_camera_toward(target_camera_position, delta)
		if tracking_target is Player:
			Global.player_spotted.emit(tracking_target.global_position, self)
	
	# lost vision on tracking_target --> start tracking_reset_timer
	elif tracking_reset_timer.is_stopped():
		tracking_reset_timer.start()


func to_camera_position(node2D: Node2D) -> CameraPosition:
	var target_direction := self.global_position.direction_to(node2D.global_position)
	var local_direction := global_transform.basis_xform_inv(target_direction)
	
	var target_camera_position := CameraPosition.new()
	target_camera_position.rotation = local_direction.angle()
	return target_camera_position


func _on_tracking_reset_timer_timeout() -> void:
	if is_controlled_by_lever() and not controlling_lever.flipped_over:
		state = CameraState.OFF
	else: #switch back to normal operation
		state = CameraState.NORMAL


func set_state(new_state: CameraState) -> void:
	if state == new_state:
		return
	state = new_state
	camera_area_2d.monitoring = CameraState.OFF != new_state
	camera_fov.visible = CameraState.OFF != new_state
	position_timer.stop()
	tracking_reset_timer.stop()


func _update_fov_polygon(circle_points := 12) -> void:
	var new_polygon := PackedVector2Array()
	var fov_step := fov / circle_points
	var current_angle := -fov_step * (circle_points / 2.0)
	
	new_polygon.append(Vector2(0.0, -8.0))
	for i in range(circle_points + 1):
		new_polygon.append(Vector2.from_angle(current_angle) * radius)
		current_angle += fov_step
	new_polygon.append(Vector2(0.0, 8.0))
	camera_fov.polygon = new_polygon
	camera_collision.polygon = new_polygon


func clamp_camera_rotation(rotation_value: float) -> float:
	var half_fov := fov / 2.0
	return clampf(rotation_value, left_limit + half_fov, right_limit - half_fov)


func rotate_camera_toward(camera_position: CameraPosition, delta := 1.0) -> void:
	if camera_position == null:
		return
	var to_rotation := camera_position.rotation
	var from := camera_area_2d.rotation
	var new_rotation := rotate_toward(from, to_rotation, rotaton_speed * delta)
	new_rotation = clamp_camera_rotation(new_rotation)
	camera_area_2d.rotation = new_rotation


func is_controlled_by_lever() -> bool:
	return controlling_lever != null


func _on_lever_flipped(flipped_over: bool) -> void:
	if flipped_over:
		set_state(CameraState.NORMAL)
	else:
		set_state(CameraState.OFF)


# debug draw
func _draw() -> void:
	if not OS.is_debug_build():
		return
	# draw_line for left and right limit
	var left_limit_point := Vector2.from_angle(left_limit) * radius
	var right_limit_point := Vector2.from_angle(right_limit) * radius
	draw_line(Vector2.ZERO, left_limit_point, Color.GREEN, 2.0)
	draw_line(Vector2.ZERO, right_limit_point, Color.RED, 2.0)
	
	if state == CameraState.TRACKING and is_instance_valid(tracking_target):
		# draw_line to tracked target for debug purposes
		var target_position := to_local(tracking_target.global_position)
		draw_line(Vector2.ZERO, target_position, Color.WHEAT, 4.0)

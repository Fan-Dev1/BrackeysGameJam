@tool
class_name SecurityCamera
extends Node2D

enum CameraState { NORMAL, TRACKING, OFF }

@export var radius := 256.0

@export_range(0.0, 360.0, 0.1, "radians_as_degrees") 
var fov := PI / 4.0
@export_range(-180.0, 180.0, 0.1, "radians_as_degrees") 
var left_limit := PI / -2.0
@export_range(-180.0, 180.0, 0.1, "radians_as_degrees") 
var right_limit := PI / 2.0

@export var rotaton_speed: float
@export var camera_position_index := 0
@export var camera_positions: Array[CameraPosition]

@onready var position_timer: Timer = $PositionTimer
@onready var tracking_timer: Timer = $TrackingTimer
@onready var camera_area_2d: Area2D = $CameraArea2D
@onready var camera_fov: Polygon2D = %CameraFov
@onready var camera_collision: CollisionPolygon2D = %CameraCollision
@onready var status_color_rect: ColorRect = %StatusColorRect

var state := CameraState.NORMAL : set = set_state


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_fov_polygon()
	var camera_pos: CameraPosition = camera_positions.get(camera_position_index)
	rotate_camera_toward(camera_pos.rotation)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		_update_fov_polygon()
		_clamp_camera_rotations()
		queue_redraw()
		var camera_pos: CameraPosition = camera_positions.get(camera_position_index)
		rotate_camera_toward(camera_pos.rotation)
	else:
		match state:
			CameraState.NORMAL: _normal_process(delta)
			CameraState.TRACKING: _tracking_process(delta)
			CameraState.OFF: pass


func _normal_process(delta: float) -> void:
	var camera_pos: CameraPosition = camera_positions.get(camera_position_index)
	rotate_camera_toward(camera_pos.rotation, delta)
	_scan_for_player()
	
	var angle_diff := angle_difference(camera_area_2d.rotation, camera_pos.rotation)
	if is_zero_approx(angle_diff) and position_timer.is_stopped():
		var duration := randf_range(camera_pos.duration_min_sec, camera_pos.duration_max_sec)
		position_timer.start(duration)


func _on_position_timer_timeout() -> void:
	# shift to next camera_position
	camera_position_index += 1
	if camera_position_index >= camera_positions.size():
		camera_position_index = 0


func _scan_for_player() -> void:
	for body: Node2D in camera_area_2d.get_overlapping_bodies():
		# alert about spotted player and track him
		if body is Player:
			Global.player_spotted.emit(body.global_position)
			state = CameraState.TRACKING


func _tracking_process(delta: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	var angle_to_player := self.global_position.angle_to_point(player.global_position)
	rotate_camera_toward(angle_to_player, delta)
	queue_redraw()
	if camera_area_2d.overlaps_body(player):
		tracking_timer.stop()
		Global.player_spotted.emit(player.global_position)
	elif tracking_timer.is_stopped():
		tracking_timer.start()


func _on_tracking_timer_timeout() -> void:
	#switch back to normal operation
	state = CameraState.NORMAL


func set_state(new_state: CameraState) -> void:
	if state == new_state:
		return
	state = new_state
	camera_area_2d.monitoring = CameraState.OFF != new_state
	camera_fov.visible = CameraState.OFF != new_state
	queue_redraw()
	position_timer.stop()
	tracking_timer.stop()


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


func _clamp_camera_rotations() -> void:
	# clamp all camera_position.rotations inside this camera left and right_limit
	for camera_position: CameraPosition in camera_positions:
		camera_position.rotation = clamp_camera_rotation(camera_position.rotation)


func clamp_camera_rotation(value: float) -> float:
	var half_fov := fov / 2.0
	return clampf(value, left_limit + half_fov, right_limit - half_fov)


func rotate_camera_toward(to: float, delta := 1.0) -> void:
	var from := camera_area_2d.rotation
	var new_rotation := rotate_toward(from, to, rotaton_speed * delta)
	new_rotation = clamp_camera_rotation(new_rotation)
	camera_area_2d.rotation = new_rotation


func _draw() -> void:
	if Engine.is_editor_hint():
		# draw_line for left and right limit
		var left_limit_point := Vector2.from_angle(left_limit) * radius
		var right_limit_point := Vector2.from_angle(right_limit) * radius
		draw_line(Vector2.ZERO, left_limit_point, Color.RED, 2.0)
		draw_line(Vector2.ZERO, right_limit_point, Color.BLUE, 2.0)
	
	if OS.is_debug_build() and state == CameraState.TRACKING:
		# draw_line to tracked player
		var player: Player = get_tree().get_first_node_in_group("player")
		var player_position := to_local(player.global_position)
		draw_line(Vector2.ZERO, player_position, Color.WHEAT, 4.0)

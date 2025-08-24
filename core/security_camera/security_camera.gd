@tool
class_name SecurityCamera
extends Node2D

enum CameraState { NORMAL, TRACKING, ALERTED, OFF }

@export var radius := 256.0
@export_range(0.0, 360.0, 0.1, "degrees") var fov_deg := 45.0
@export var left_limit_deg := -90.0 
@export var right_limit_deg := 90.0 

@export var rotaton_speed := 1.0
@export var camera_position_index := 0
@export var camera_positions: Array[CameraPosition]

@onready var position_timer: Timer = $PositionTimer
@onready var camera_area_2d: Area2D = $CameraArea2D
@onready var camera_fov: Polygon2D = %CameraFov
@onready var camera_collision: CollisionPolygon2D = %CameraCollision

var state := CameraState.NORMAL


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var new_polygon := calculate_fov_polygon()
	camera_fov.polygon = new_polygon
	camera_collision.polygon = new_polygon
	var camera_pos: CameraPosition = camera_positions.get(camera_position_index)
	camera_area_2d.rotation_degrees = camera_pos.angle_deg
	var duration := randf_range(camera_pos.duration_min_sec, camera_pos.duration_max_sec)
	position_timer.start(duration)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		var camera_pos: CameraPosition = camera_positions.get(camera_position_index)
		camera_area_2d.rotation_degrees = camera_pos.angle_deg
		return
	
	match state:
		CameraState.NORMAL:
			normal_process(delta)
		CameraState.TRACKING:
			track_player(delta)


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	
	var left_limit_point := Vector2.from_angle(deg_to_rad(left_limit_deg)) * radius
	var right_limit_point := Vector2.from_angle(deg_to_rad(right_limit_deg)) * radius
	draw_line(Vector2.ZERO, left_limit_point, Color.RED, 2.0)
	draw_line(Vector2.ZERO, right_limit_point, Color.BLUE, 2.0)


func normal_process(delta: float) -> void:
	var camera_pos: CameraPosition = camera_positions.get(camera_position_index)
	var rotation_difference := camera_pos.angle_deg - camera_area_2d.rotation_degrees
	rotation_difference = clampf(rotation_difference, -rotaton_speed, rotaton_speed)
	camera_area_2d.rotation_degrees += rotation_difference
	camera_area_2d.rotation_degrees = clampf(camera_area_2d.rotation_degrees, left_limit_deg, right_limit_deg)
	
	if rotation_difference == 0.0 and position_timer.is_stopped():
		var duration := randf_range(camera_pos.duration_min_sec, camera_pos.duration_max_sec)
		position_timer.start(duration)


func track_player(delta: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	var angle_to_player := self.global_position.angle_to_point(player.global_position)
	var rotation_difference := camera_area_2d.rotation_degrees - angle_to_player
	rotation_difference = clampf(rotation_difference, -rotaton_speed, rotaton_speed)
	camera_area_2d.rotation_degrees += rotation_difference


func calculate_fov_polygon(circle_points := 12) -> PackedVector2Array:
	var new_polygon := PackedVector2Array()
	new_polygon.append(Vector2(0.0, -8.0))
	var fov_rad_step := deg_to_rad(fov_deg / circle_points)
	var current_angle := -fov_rad_step * (circle_points / 2.0)
	for i in range(circle_points + 1):
		var half_fov_rad := deg_to_rad((fov_deg / 2.0))
		new_polygon.append(Vector2.from_angle(current_angle) * radius)
		current_angle += fov_rad_step
	new_polygon.append(Vector2(0.0, 8.0))
	return new_polygon


func _on_position_timer_timeout() -> void:
	camera_position_index += 1
	if camera_position_index >= camera_positions.size():
		camera_position_index = 0


func _on_camera_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.player_spotted.emit(body.global_position)

@tool
class_name SecurityGuard
extends Node2D

enum GuardState { NORMAL, TRACKING, MOVING, OFF }

@export var radius := 256.0

@export_range(0.0, 360.0, 0.1, "radians_as_degrees") 
var fov := PI / 4.0
#@export_range(-180.0, 180.0, 0.1, "radians_as_degrees") 
#var left_limit := PI / -2.0
#@export_range(-180.0, 180.0, 0.1, "radians_as_degrees") 
#var right_limit := PI / 2.0

@export var rotaton_speed: float
@export var move_speed: float = 1.0
@export var guard_position_index := 0
@export var guard_positions: Array[GuardPosition]

@onready var position_timer: Timer = $positionTimer
@onready var tracking_timer: Timer = $trackingTimer
@onready var guard_area_2d: Area2D = $GuardArea2D
@onready var guard_fov: Polygon2D = %GuardFov
@onready var guard_collision: CollisionPolygon2D = %GuardCollision



var state := GuardState.NORMAL : set = set_state
var detected := "Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_fov_polygon()
	var guard_pos: GuardPosition = guard_positions.get(guard_position_index)
	rotate_camera_toward(guard_pos.rotation)
	var duration := randf_range(guard_pos.duration_min_sec, guard_pos.duration_max_sec)
	position_timer.start(duration)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		_update_fov_polygon()
		#_clamp_camera_rotations()
		queue_redraw()
		var guard_pos: GuardPosition = guard_positions.get(guard_position_index)
		rotate_camera_toward(guard_pos.rotation)
	else:
		match state:
			GuardState.NORMAL: _normal_process(delta)
			GuardState.TRACKING: _tracking_process(delta)
			#GuardState.MOVING: _moving_process(delta)
			GuardState.OFF: pass


func _normal_process(delta: float) -> void:
	var guard_pos: GuardPosition = guard_positions.get(guard_position_index)
	_scan_for_player()
	rotate_camera_toward(guard_pos.rotation, delta)
	move_guard_toward(guard_pos.target_marker, delta)
	var angle_difference := angle_difference(guard_area_2d.rotation, guard_pos.rotation)
	if is_zero_approx(angle_difference) and position_timer.is_stopped():
		var duration := randf_range(guard_pos.duration_min_sec, guard_pos.duration_max_sec)
		position_timer.start(duration)


func _on_position_timer_timeout() -> void:
	# shift to next camera_position
	guard_position_index += 1
	if guard_position_index >= guard_positions.size():
		guard_position_index = 0


func _tracking_process(delta: float) -> void:
	if detected == "player" or detected == "cookie_projectile":
		
		var target := get_tree().get_first_node_in_group(detected)
		
		if is_instance_valid(target):
			
			var angle_to_target := self.global_position.angle_to_point(target.global_position)
			rotate_camera_toward(angle_to_target, delta)
		
			if guard_area_2d.overlaps_body(target) and target:
				tracking_timer.stop()
			elif tracking_timer.is_stopped():
				tracking_timer.start()
			
		elif tracking_timer.is_stopped():
			tracking_timer.start()
		queue_redraw()


func _on_tracking_timer_timeout() -> void:
	#switch back to normal operation
	state = GuardState.NORMAL


func _scan_for_player() -> void:
	for body: Node2D in guard_area_2d.get_overlapping_bodies():
		# alert about spotted player and track him
		if body is Player:
			detected = "player"
			Global.player_spotted.emit(body.global_position)
			state = GuardState.TRACKING
		elif body is CookieProjectile: #elif so if both cookie and player, follow player
			detected = "cookie_projectile"
			state = GuardState.TRACKING

func set_state(new_state: GuardState) -> void:
	if state == new_state:
		return
	state = new_state
	guard_area_2d.monitoring = GuardState.OFF != new_state
	guard_fov.visible = GuardState.OFF != new_state
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
	guard_fov.polygon = new_polygon
	guard_collision.polygon = new_polygon

func rotate_camera_toward(to: float, delta := 1.0) -> void:
	var from := guard_area_2d.rotation
	var new_rotation := rotate_toward(from, to, rotaton_speed * delta)
#	new_rotation = clamp_camera_rotation(new_rotation)
	guard_area_2d.rotation = new_rotation

#func _moving_process(delta: float)

func move_guard_toward(to: Vector2, delta : float):
	
	position = position.move_toward(position + to, move_speed * delta)
	
	

func _draw() -> void:
	if Engine.is_editor_hint():
		# draw_line for left and right limit
		var half_fov := fov / 2.0
		#var left_limit_point := Vector2.from_angle(left_limit) * radius
		#var right_limit_point := Vector2.from_angle(right_limit) * radius
		#draw_line(Vector2.ZERO, left_limit_point, Color.RED, 2.0)
		#draw_line(Vector2.ZERO, right_limit_point, Color.BLUE, 2.0)
	
	if OS.is_debug_build() and state == GuardState.TRACKING:
		# draw_line to tracked player
		var player: Player = get_tree().get_first_node_in_group("player")
		var player_position := to_local(player.global_position)
		draw_line(Vector2.ZERO, player_position, Color.WHEAT, 4.0)

@tool
class_name SecurityCamera
extends Node2D

enum CameraState { NORMAL, TRACKING, OFF }

@export var controlling_lever: LeverButton
@export var assigned_guard: SecurityGuard

@export var rotaton_speed: float
@export_range(-180.0, 180.0, 0.1, "radians_as_degrees") 
var left_limit := PI / -2.0
@export_range(-180.0, 180.0, 0.1, "radians_as_degrees") 
var right_limit := PI / 2.0

@export var camera_position_index := 0
@export var camera_positions: Array[CameraPosition] = []

var state := CameraState.NORMAL : set = set_state
var tracking_target: Node2D


@onready var position_timer: Timer = $PositionTimer
@onready var tracking_reset_timer: Timer = $TrackingResetTimer

@onready var pivot_point: Node2D = %PivotPoint
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var status_color_rect: ColorRect = %StatusColorRect
@onready var vision_cone: VisionCone = %VisionCone


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	vision_cone.body_spotted.connect(_on_body_spotted)
	_ready_camera_rotation()
	if is_controlled_by_lever():
		controlling_lever.lever_flipped.connect(_on_lever_flipped)
	if !assigned_guard:
		push_warning("no guard assigned - fallback to first guard in tree")
		assigned_guard = get_tree().get_first_node_in_group("Guard")


func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_EDITOR_PRE_SAVE:
		camera_position_index = 0
		_ready_camera_rotation()


func _on_body_spotted(body_spotted_event: VisionCone.BodySpottedEvent) -> void:
	pass


func _ready_camera_rotation() -> void:
	if not camera_positions.is_empty():
		camera_position_index = wrapi(camera_position_index, 0, camera_positions.size())
		var camera_position := camera_positions[camera_position_index]
		rotate_camera_toward(camera_position)


func _physics_process(delta: float) -> void:
	if OS.is_debug_build():
		queue_redraw()
	if Engine.is_editor_hint():
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
	var at_rotation := rotate_camera_toward(camera_position, delta)
	_scan_for_player()
	# if camera reached camera_position --> start position_timer
	if at_rotation and position_timer.is_stopped():
		var duration := randf_range(camera_position.duration_min_sec, camera_position.duration_max_sec)
		position_timer.start(duration)


func _scan_for_player() -> void:
	for body: Node2D in vision_cone.get_overlapping_bodies():
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
	
	if vision_cone.overlaps_body(tracking_target):
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
	vision_cone.monitoring = CameraState.OFF != new_state
	position_timer.stop()
	tracking_reset_timer.stop()


func clamp_camera_rotation(rotation_value: float) -> float:
	var half_fov := vision_cone.vision_cone_config.fov / 2.0
	return clampf(rotation_value, left_limit + half_fov, right_limit - half_fov)


func rotate_camera_toward(camera_position: CameraPosition, delta := 1.0) -> bool:
	if camera_position == null:
		return true
	var from := pivot_point.rotation
	var to :=  camera_position.rotation
	var new_rotation := rotate_toward(from, to, rotaton_speed * delta)
	new_rotation = clamp_camera_rotation(new_rotation)
	pivot_point.rotation = new_rotation
	var angle_diff := angle_difference(pivot_point.rotation, clamp_camera_rotation(camera_position.rotation))
	return is_zero_approx(angle_diff)


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
	var radius := vision_cone.vision_cone_config.radius
	var left_limit_point := Vector2.from_angle(left_limit) * radius
	var right_limit_point := Vector2.from_angle(right_limit) * radius
	draw_line(Vector2.ZERO, left_limit_point, Color.GREEN, 2.0)
	draw_line(Vector2.ZERO, right_limit_point, Color.RED, 2.0)
	
	if state == CameraState.TRACKING and is_instance_valid(tracking_target):
		# draw_line to tracked target for debug purposes
		var target_position := to_local(tracking_target.global_position)
		draw_line(Vector2.ZERO, target_position, Color.WHEAT, 4.0)

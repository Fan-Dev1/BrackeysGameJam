class_name Door
extends Node2D

enum State { OPEN, CLOSED, PEAKING }

@export var door_speed: float
@export var door_state := State.CLOSED

@onready var slide_door: AnimatableBody2D = $SlideDoor
@onready var border_line_2d: Line2D = %BorderLine2D
@onready var visually_node: Node2D = %VisuallyNode

@onready var interation_area_2d: Area2D = %InterationArea2D
@onready var squeeze_area_2d: Area2D = %SqueezeArea2D

@onready var up_peek_light: PointLight2D = %UpPeekPointLight2D
@onready var down_peek_light: PointLight2D = %DownPeekPointLight2D


func _ready() -> void:
	if door_state == State.CLOSED:
		slide_door.set_position.call_deferred(get_slide_position())
	border_line_2d.visible = false
	stop_peeking()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		handle_interation()
	_slide_door(delta)


func _slide_door(delta: float) -> void:
	var slide_position := get_slide_position()
	var weight := 1 - exp(-door_speed * delta)
	slide_door.position = slide_door.position.lerp(slide_position, weight)
	
	# visually faked door peaking
	if door_state == State.PEAKING:
		var peak_position := Vector2.RIGHT * 20.0
		visually_node.position = visually_node.position.lerp(peak_position, weight * 2.0)
	else:
		visually_node.position = visually_node.position.lerp(Vector2.ZERO, weight * 2.0)


func get_slide_position() -> Vector2:
	if door_state == State.OPEN:
		var door_width := border_line_2d.get_point_position(1).x
		return Vector2.RIGHT * door_width
	elif squeeze_area_2d.get_overlapping_bodies(): # closing blocked by body
		return slide_door.position - Vector2.LEFT * 8.0
	else: # PEAKING, CLOSED
		return Vector2.ZERO


func start_peeking(from_position: Vector2) -> void:
	var peek_direction := global_position.direction_to(from_position)
	var local_direction: Vector2 = transform.basis_xform_inv(peek_direction)
	var is_on_up_side := local_direction.dot(Vector2.UP) > 0.0
	down_peek_light.enabled = is_on_up_side
	up_peek_light.enabled = not is_on_up_side
	print("peak up " + str(is_on_up_side))
	door_state = State.PEAKING


func stop_peeking() -> void:
	up_peek_light.enabled = false
	down_peek_light.enabled = false
	door_state = State.CLOSED


func open_door() -> void:
	stop_peeking()
	door_state = State.OPEN


func close_door() -> void:
	door_state = State.CLOSED


func _on_interation_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		border_line_2d.visible = true


func _on_interation_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		border_line_2d.visible = false
		if door_state == State.PEAKING:
			stop_peeking()


func handle_interation() -> void:
	var player := Global.get_player()
	var in_reach_for_interation := border_line_2d.visible
	if in_reach_for_interation:
		if door_state == State.OPEN: # open --> closed
			print("close " + self.name)
			close_door()
		elif door_state == State.PEAKING: # peaking --> open
			print("open " + self.name)
			open_door()
		elif slide_door.position.x < 20.0: # closed --> peaking
			print("peaking " + self.name)
			start_peeking(player.global_position)

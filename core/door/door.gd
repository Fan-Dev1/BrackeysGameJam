class_name Door
extends Node2D


@export var smoothing: float
@export var open := false

@onready var slide_door: AnimatableBody2D = $SlideDoor
@onready var border_line_2d: Line2D = %BorderLine2D
@onready var door_width: float = %Sprite.size.x

@onready var interation_area_2d: Area2D = %InterationArea2D
@onready var squeeze_area_2d: Area2D = %SqueezeArea2D

@onready var up_peek_light: PointLight2D = %UpPeekPointLight2D
@onready var down_peek_light: PointLight2D = %DownPeekPointLight2D


func _ready() -> void:
	border_line_2d.visible = false
	stop_peeking()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		var player := Global.get_player()
		if interation_area_2d.overlaps_body(player):
			if open:
				close_door()
			elif is_peeking():
				open_door()
			else:
				start_peeking(player.global_position)
	
	# slide door
	if open:
		_slide_door(Vector2.RIGHT * door_width, delta)
	elif is_peeking():
		_slide_door(Vector2.RIGHT * 20.0, delta)
	elif not squeeze_area_2d.get_overlapping_bodies(): # close
		_slide_door(Vector2.ZERO, delta)


func _slide_door(to_position: Vector2, delta: float) -> void:
	var weight := 1 - exp(-smoothing * delta)
	slide_door.position = slide_door.position.lerp(to_position, weight)


func start_peeking(from_position: Vector2) -> void:
	var peek_direction := global_position.direction_to(from_position)
	var is_on_up_side := peek_direction.dot(Vector2.DOWN) > 0.0
	up_peek_light.enabled = not is_on_up_side
	down_peek_light.enabled = is_on_up_side

func stop_peeking() -> void:
	up_peek_light.enabled = false
	down_peek_light.enabled = false

func is_peeking() -> bool:
	return up_peek_light.enabled or down_peek_light.enabled


func open_door() -> void:
	open = true
	stop_peeking()

func close_door() -> void:
	open = false


func _on_interation_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		border_line_2d.visible = true


func _on_interation_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		border_line_2d.visible = false
		stop_peeking()

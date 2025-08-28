class_name HidingSpot
extends Area2D

@export var enter_duration: float

var occupied := false

@onready var player_marker: Marker2D = $PlayerMarker2D
@onready var player_placeholder_sprite: AnimatedSprite2D = %PlayerAnimatedSprite2D
@onready var outline_sprite: Sprite2D = %OutlineSprite2D
@onready var vision_point_light: PointLight2D = %VisionPointLight2D
@onready var camera_2d: Camera2D = %Camera2D


func _ready() -> void:
	outline_sprite.visible = false
	player_placeholder_sprite.visible = false
	vision_point_light.visible = false


func _unhandled_input(event: InputEvent) -> void:
	var in_reach_for_interation := outline_sprite.visible
	if event.is_action_pressed("interact"):
		if occupied:
			stop_hiding()
		elif in_reach_for_interation:
			start_hiding()


func start_hiding() -> void:
	var player := Global.get_player()
	var from_position := player.global_position
	var final_position := player_marker.global_position
	player.player_is_hidden = true
	player.process_mode = Node.PROCESS_MODE_DISABLED
	player.global_position = final_position
	player.visible = false
	player_placeholder_sprite.visible = true
	
	vision_point_light.visible = true
	outline_sprite.visible = false
	camera_2d.enabled = true
	camera_2d.make_current()
	occupied = true
	
	var tween := create_tween()
	tween.tween_property(player_placeholder_sprite, \
			"global_position", final_position, enter_duration) \
		.from(from_position) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)


func stop_hiding() -> void:
	var player := Global.get_player()
	player.global_position = player_placeholder_sprite.global_position
	player.process_mode = Node.PROCESS_MODE_INHERIT
	player.visible = true
	player.player_is_hidden = false
	outline_sprite.visible = true
	
	player_placeholder_sprite.visible = false
	vision_point_light.visible = false
	occupied = false
	camera_2d.enabled = false


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		outline_sprite.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		outline_sprite.visible = false

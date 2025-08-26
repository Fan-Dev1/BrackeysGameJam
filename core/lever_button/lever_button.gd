@tool
class_name LeverButton
extends Node2D

signal lever_flipped(flipped_over: bool)

@export var flipped_over := true : set = set_flipped_over

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var outline_animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D/OutlineAnimatedSprite2D
@onready var lever_flip_sfx: AudioStreamPlayer = $LeverFlipSfx


func _ready() -> void:
	outline_animated_sprite_2d.visible = false
	lever_flipped.emit.call_deferred(flipped_over)
	if flipped_over:
		var last_frame = animated_sprite_2d.sprite_frames.get_frame_count(&"turn_on") - 1
		animated_sprite_2d.frame = last_frame
		outline_animated_sprite_2d.frame = last_frame


func _unhandled_input(event: InputEvent) -> void:
	var in_reach_for_interation := outline_animated_sprite_2d.visible
	if event.is_action_pressed("interact") and in_reach_for_interation:
		set_flipped_over(not flipped_over)


func set_flipped_over(_flipped_over: bool) -> void:
	var changed := flipped_over != _flipped_over
	flipped_over = _flipped_over
	if not changed or not is_node_ready():
		return
	
	lever_flipped.emit(flipped_over)
	if flipped_over:
		animated_sprite_2d.play(&"turn_on")
		outline_animated_sprite_2d.play(&"turn_on")
		lever_flip_sfx.play()
	else:
		animated_sprite_2d.play_backwards(&"turn_on")
		outline_animated_sprite_2d.play_backwards(&"turn_on")
		lever_flip_sfx.play()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		outline_animated_sprite_2d.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		outline_animated_sprite_2d.visible = false

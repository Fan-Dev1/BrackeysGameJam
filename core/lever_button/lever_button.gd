class_name LeverButton
extends Node2D

signal lever_flipped(flipped_over: bool)

@export var flipped_over := true : set = set_flipped_over

@onready var lever_flip_sfx: AudioStreamPlayer = $LeverFlipSfx
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var outline_sprite_2d: Sprite2D = $Sprite2D/OutlineSprite2D


func _ready() -> void:
	outline_sprite_2d.visible = false
	lever_flipped.emit.call_deferred(flipped_over)
	if not flipped_over:
		sprite_2d.frame = 4
		outline_sprite_2d.frame = 4


func _unhandled_input(event: InputEvent) -> void:
	var in_reach_for_interation := outline_sprite_2d.visible
	if event.is_action_pressed("interact") and in_reach_for_interation:
		set_flipped_over(not flipped_over)


func set_flipped_over(_flipped_over: bool) -> void:
	var changed := flipped_over != _flipped_over
	flipped_over = _flipped_over
	if not changed or not is_node_ready():
		return
	
	lever_flipped.emit(flipped_over)
	if flipped_over:
		animation_player.play(&"turn_on")
		lever_flip_sfx.play()
	else:
		animation_player.play(&"turn_off")
		lever_flip_sfx.play()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		outline_sprite_2d.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		outline_sprite_2d.visible = false

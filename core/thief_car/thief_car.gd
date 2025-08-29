class_name ThiefCar
extends CharacterBody2D

signal car_entered
signal car_exited
signal cookie_dropped

enum CarFrame { 
	NORMAL=0, CABIN_OUTLINE=1, CARGO_BED_OUTLINE=2,
}

var player_inside := false

@onready var car_sprite_2d: Sprite2D = %CarSprite2D
@onready var head_lights: PointLight2D = %HeadLights
@onready var tail_lights: PointLight2D = %TailLights
@onready var interaction_area_2d = %InteractionArea2D


func _ready() -> void:
	car_sprite_2d.frame = CarFrame.NORMAL


func _physics_process(delta):
	var player :=  _find_overlapping_player()
	if player == null:
		car_sprite_2d.frame = CarFrame.NORMAL
	else:
		_update_interaction_outline(player)


func _update_interaction_outline(player: Player) -> void:
	var direction_player := self.global_position.direction_to(player.global_position)
	var on_right_side := direction_player.dot(Vector2.RIGHT) > 0.0
	if on_right_side:
		car_sprite_2d.frame = CarFrame.CABIN_OUTLINE
	else:
		car_sprite_2d.frame = CarFrame.CARGO_BED_OUTLINE


func _find_overlapping_player() -> Player:
	for body in interaction_area_2d.get_overlapping_bodies():
		if body is Player:
			return body
	return null


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_handle_interact_input()


func _handle_interact_input() -> void:
	if player_inside:
		player_inside = false
		car_exited.emit()
	elif car_sprite_2d.frame == CarFrame.CABIN_OUTLINE:
		player_inside = true
		car_entered.emit()
	elif car_sprite_2d.frame == CarFrame.CARGO_BED_OUTLINE:
		cookie_dropped.emit()

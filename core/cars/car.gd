class_name Car
extends CharacterBody2D

signal car_entered
signal car_exited


var player_inside := false

@onready var car_sprite_2d: Sprite2D = %CarSprite2D
@onready var head_lights: PointLight2D = %HeadLights
@onready var tail_lights: PointLight2D = %TailLights


func _ready() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	var in_reach_for_interation := car_sprite_2d.use_parent_material == false
	if event.is_action_pressed("interact") and player_inside:
		car_exited.emit()
	elif event.is_action_pressed("interact") and in_reach_for_interation:
		car_entered.emit()


func _on_interaction_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		car_sprite_2d.use_parent_material = false


func _on_interaction_area_2d_body_exited(body: Node2D) -> void:
	if body is Player and not player_inside:
		car_sprite_2d.use_parent_material = true


func _on_car_entered() -> void:
	car_sprite_2d.use_parent_material = false

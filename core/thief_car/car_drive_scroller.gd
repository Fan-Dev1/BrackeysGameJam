class_name CarDriverScroller
extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var thief_car: ThiefCar = %ThiefCar


func _ready() -> void:
	pass # Replace with function body.


func play_drive_in() -> void:
	animation_player.play("drive_in")


func play_drive_out() -> void:
	animation_player.play("drive_out")


func play_enter_driving() -> void:
	animation_player.play("enter_driving")


func play_exit_driving() -> void:
	animation_player.play("exit_driving")

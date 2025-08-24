class_name Player 
extends CharacterBody2D


@export var move_speed: float
@export var move_smothing: float

@onready var camera_2d: Camera2D = %Camera2D

var has_cookie := false


func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity := input_direction * move_speed
	
	var velocity_weight := 1.0 - exp(-move_smothing * delta)
	velocity = velocity.lerp(target_velocity, velocity_weight)
	move_and_slide()


func take_cookie_from(from: CookieStash):
	has_cookie = true


func drop_of_cookie():
	has_cookie = false

class_name Player 
extends CharacterBody2D


@export var move_speed: float
@export var move_smothing: float

@onready var camera_2d: Camera2D = %Camera2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var has_cookie := false
var last_direction := Vector2.DOWN

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity := input_direction * move_speed
	if input_direction:
		last_direction = input_direction
	manage_animations(input_direction, last_direction)
	var velocity_weight := 1.0 - exp(-move_smothing * delta)
	velocity = velocity.lerp(target_velocity, velocity_weight)
	move_and_slide()

func manage_animations(input_direction, last_direction) -> void:
	var anim_state : String
	var dir = input_direction if input_direction else last_direction
	if input_direction:
		anim_state = "Walk"
	else:
		anim_state = "Idle"
	if dir.y > 0:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play(anim_state + "South")
	elif dir.y < 0: 
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play(anim_state +"North")
		
	elif dir.x > 0:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play(anim_state +"East")
		
	elif dir.x < 0:
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.play(anim_state +"East")
	
func take_cookie_from(from: CookieStash):
	has_cookie = true


func drop_of_cookie():
	has_cookie = false


func take_damage(damage: int):
	# TODO take_damage
	pass

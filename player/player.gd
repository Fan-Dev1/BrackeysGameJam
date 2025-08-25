class_name Player 
extends CharacterBody2D


@export var move_speed: float
@export var move_smothing: float

@onready var camera_2d: Camera2D = %Camera2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var max_line_length: float = 300.0

@export var dot_size: float = 10.0
@export var gap_size: float = 15.0

var target_pos: Vector2
var has_cookie := false
var last_direction := Vector2.DOWN

var cookie_proyectile := preload("res://core/cookie_proyectile/cookie_projectile.tscn")

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity := input_direction * move_speed
	if input_direction:	
		last_direction = input_direction
	manage_animations(input_direction, last_direction)
	var velocity_weight := 1.0 - exp(-move_smothing * delta)
	velocity = velocity.lerp(target_velocity, velocity_weight)
	if Input.is_action_pressed("fire"):
		aim()
	elif Input.is_action_just_released("fire"):
		fire()
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

func aim() -> void:
	target_pos = get_local_mouse_position().limit_length(max_line_length)
	queue_redraw()

func fire() -> void:
	
	var new_cookie = cookie_proyectile.instantiate()
	get_parent().add_child(new_cookie)
	new_cookie.fired(to_global(target_pos), global_position) 
	target_pos = Vector2.ZERO
	queue_redraw()
func _draw() -> void:
	var current_pos = Vector2.ZERO
	var direction = target_pos.normalized()
	gap_size = target_pos.length() / 10
	# Keep drawing dots until we reach the target position
	
	
	while current_pos.length() < target_pos.length():
		# Draw one dot (a short line segment)
		draw_line(current_pos, current_pos + direction * dot_size, "White", 5.0)
		
		# Move forward past the dot and the gap
		current_pos += direction * (dot_size + gap_size)
	draw_circle(target_pos, 15, "Black")
	draw_circle(target_pos, 10, "White")
func take_cookie_from(from: CookieStash):
	has_cookie = true


func drop_of_cookie():
	has_cookie = false


func take_damage(damage: int):
	# TODO take_damage
	pass

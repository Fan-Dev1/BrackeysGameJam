class_name CookieProjectile
extends CharacterBody2D

var target_position = Vector2.ZERO

var friction 
var travelTime := 1.2
var spawn_position
@onready var area_2d: Area2D = $Area2D
@onready var death_timer: Timer = $DeathTimer
@onready var timer: Timer = $DeathTimer/Timer

func fired(target : Vector2, spawn : Vector2):
	
	position = spawn
	target_position = target
	velocity = (target - spawn).normalized() * 850
func _physics_process(delta: float) -> void:
	
	if is_on_floor() or is_on_ceiling() or is_on_wall():
		destroyed() #animations here
	if global_position.distance_to(target_position) < 10:
		
		destroyed() #and here
	move_and_slide()
	
	
func destroyed() -> void:
	#self.visible = false
	velocity = Vector2.ZERO
	
	if timer.is_stopped():
		timer.start()

	
	

func _on_timer_timeout() -> void:
	area_2d.monitorable = false
	death_timer.start
	self.remove_from_group("cookie_projectile")
	queue_free()

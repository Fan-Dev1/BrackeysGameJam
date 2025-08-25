extends CharacterBody2D

var target_position = Vector2.ZERO

var friction 
var travelTime := 1.2
var spawn_position
func fired(target : Vector2, spawn : Vector2):
	
	position = spawn
	target_position = target
	velocity = (target - spawn).normalized() * 300
func _physics_process(delta: float) -> void:
	
	if is_on_floor() or is_on_ceiling() or is_on_wall():
		queue_free()
	if global_position.distance_to(target_position) < 10:
		queue_free() 
	move_and_slide()
	print(global_position, to_global(target_position))
	


func _on_death_timer_timeout() -> void:
	queue_free()

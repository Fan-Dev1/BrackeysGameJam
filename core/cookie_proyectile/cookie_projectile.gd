extends CharacterBody2D

var target_position = Vector2.ZERO

var friction 
var travelTime := 1.2
func fired(target : Vector2, spawn_position : Vector2):
	position = spawn_position
	target_position = target
	velocity = target 
func _physics_process(delta: float) -> void:
	friction = velocity.length() / travelTime
	if is_on_floor() or is_on_ceiling() or is_on_wall():
		velocity = Vector2.ZERO
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	velocity = velocity.move_toward(Vector2.ZERO, 10 * delta)
	#fuck me here dont know why i struggled with this simple bs, wanted the cookie to always end up in the
	#crosshair, this kinda does it well without it feeling like total ice
	move_and_slide()
	

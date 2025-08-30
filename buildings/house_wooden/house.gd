extends Area2D

@onready var animation_player = $AnimationPlayer

var player_inside := false

func _on_body_entered(body):
	player_inside = true
	animation_player.stop()
	animation_player.play("enter_transition")

func _on_body_exited(body):
	player_inside = false
	animation_player.stop()
	animation_player.play("exit_transition")

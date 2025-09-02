extends Area2D


@onready var level_mockup: Sprite2D = $LevelMockup
@onready var camera_2d: Camera2D = $Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_2d.enabled = false
	level_mockup.self_modulate = Color.TRANSPARENT


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		level_mockup.self_modulate = Color.WHITE
		camera_2d.enabled = true
		camera_2d.make_current()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		level_mockup.self_modulate = Color.TRANSPARENT
		camera_2d.enabled = false

extends Node


var spotted_by_detection_beam := false
var spotted_by_security_camera := false

@onready var level: Level


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent() is Level:
		push_warning("Expect Level as parent")
	level = get_parent()
	Global.player_spotted.connect(_on_player_spotted)


func _on_player_spotted(position: Vector2, device: Node2D) -> void:
	if device is DetectionBeam:
		spotted_by_detection_beam = true
	if device is SecurityCamera:
		spotted_by_security_camera = true


func update_mission_goals() -> void:
	var level_goals := level.level_mission.level_goals
	var detection_beam_goal := level_goals[1]
	detection_beam_goal.goal_reached = not spotted_by_detection_beam
	var detection_camera_goal := level_goals[2]
	detection_camera_goal.goal_reached = spotted_by_security_camera
